# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  accept_terms           :boolean
#  active                 :boolean          default(TRUE)
#  api_token              :string(255)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(80)       default(""), not null
#  encrypted_password     :string(255)
#  firstname              :string(255)
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_token       :string(255)
#  invited_by_type        :string(255)
#  last_api_access        :datetime
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  other_organisation :string
#  recovery_email         :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0)
#  surname                :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  department_id          :integer
#  invited_by_id          :integer
#  language_id            :integer
#  org_id                 :integer
#
# Indexes
#
#  fk_rails_45f4f12508    (language_id)
#  fk_rails_f29bf9cdf2    (department_id)
#  index_users_on_email   (email)
#  index_users_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (org_id => orgs.id)
#

# Object that represents a User
class User < ApplicationRecord
  include ConditionalUserMailer
  include DateRangeable
  include Identifiable

  include Dmptool::User

  extend UniqueRandom

  # DMPTool customization
  #
  # commenting out Devise which we re-implement below
  #
  ##
  # Devise
  #   Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  # devise :invitable, :database_authenticatable, :registerable, :recoverable,
  #        :rememberable, :trackable, :validatable, :omniauthable,
  #        omniauth_providers: %i[shibboleth orcid]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[shibboleth orcid]

  # DMPTool customization
  #
  # Alias 'institution' for 'org'
  attr_accessor :institution

  ##
  # User Notification Preferences
  serialize :prefs, Hash

  # default user language to the default language
  attribute :language_id, :integer, default: -> { Language.default&.id }

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :perms, join_table: :users_perms

  belongs_to :language

  # DMPTool customization
  #
  # commenting out because we make it optional in Dmptool::User concern
  #
  # belongs_to :org
  belongs_to :org, optional: true

  # Added to allow creation of Orgs at sign up / edit profile
  accepts_nested_attributes_for :org

  belongs_to :department, required: false

  has_one  :pref

  has_many :answers

  has_many :notes

  has_many :exported_plans

  has_many :roles, dependent: :destroy

  has_many :plans, through: :roles

  has_and_belongs_to_many :notifications, dependent: :destroy,
                                          join_table: 'notification_acknowledgements'

  # ===============
  # = Validations =
  # ===============

  validates :active, inclusion: { in: BOOLEAN_VALUES, message: INCLUSION_MESSAGE }

  validates :firstname, presence: { message: PRESENCE_MESSAGE }

  validates :surname, presence: { message: PRESENCE_MESSAGE }

  # DMPTool customization
  #
  # commenting out Devise which we re-implement in the Dmptool::User concern
  #
  # validates :org, presence: { message: PRESENCE_MESSAGE }

  # Validations to support ouur sign in / sign up workflow
  validates :institution, presence: { message: PRESENCE_MESSAGE }
  validates :accept_terms, inclusion: { in: [true, nil], message: _('and conditions') }

  # DMPTool customization
  #
  # Associations to support Doorkeeper security for API v2
  #
  # Access Grants are created when a user authorizes an ApiClient to access their
  # data via the OAuth workflow. They are sent back to the ApiClient as 'code' which
  # is in turn used to retrieve an AccessToken
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all

  # Access Tokens are created when an ApiClient authenticates a User via an access
  # grant code. The access token is then used instead of credentials in calls to the
  # API. These tokens can be revoked by a user on their profile page.
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all

  # Table that stores OAuth access tokens for other external systems like ORCID
  has_many :external_api_access_tokens, dependent: :destroy
  accepts_nested_attributes_for :external_api_access_tokens
  accepts_nested_attributes_for :plans

  # ==========
  # = Scopes =
  # ==========

  # because of the way this generates SQL it breaks with > 65k users
  # needs rethought
  # default_scope { includes(:org, :perms) }

  # Retrieves all of the org_admins for the specified org
  scope :org_admins, lambda { |org_id|
    joins(:perms).where('users.org_id = ? AND perms.name IN (?) AND ' \
                        'users.active = ?',
                        org_id,
                        %w[grant_permissions
                           modify_templates
                           modify_guidance
                           change_org_details],
                        true)
  }

  scope :search, lambda { |term|
    if date_range?(term: term)
      by_date_range(:created_at, term)
    else
      search_pattern = "%#{term}%"
      # MySQL does not support standard string concatenation and since concat_ws
      # or concat functions do not exist for sqlite, we have to come up with this
      # conditional
      if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
        where("lower(concat_ws(' ', firstname, surname)) LIKE lower(?) OR " \
              'lower(email) LIKE lower(?)',
              search_pattern, search_pattern)
      else
        joins(:org)
          .where("lower(firstname || ' ' || surname) LIKE lower(:search_pattern)
                    OR lower(email) LIKE lower(:search_pattern)
                    OR lower(orgs.name) LIKE lower (:search_pattern)
                    OR lower(orgs.abbreviation) LIKE lower (:search_pattern) ",
                 search_pattern: search_pattern)
      end
    end
  }

  # =============
  # = Callbacks =
  # =============

  # sanitise html tags from fields
  before_validation ->(data) { data.sanitize_fields(:email, :firstname, :surname) }

  after_update :clear_department_id, if: :saved_change_to_org_id?

  after_update :delete_perms!, if: :saved_change_to_org_id?, unless: :can_change_org?

  after_update :remove_token!, if: :saved_change_to_org_id?, unless: :can_change_org?

  # DMPTool customization
  #
  # Callbacks to support our sign in / sign up workflow
  before_validation ->(user) { user.institution = user.org }

  # =================
  # = Class methods =
  # =================

  # DMPTool customization
  #
  # commenting out Devise which we re-implement in the Dmptool::User concern
  #
  # Load the user based on the scheme and id provided by the Omniauth call
  # def self.from_omniauth(auth)
  #   Identifier.by_scheme_name(auth.provider.downcase, "User")
  #             .where(value: auth.uid)
  # end

  def self.to_csv(users)
    User::AtCsv.new(users).to_csv
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # This method uses Devise's built-in handling for inactive users
  #
  # Returns Boolean
  def active_for_authentication?
    super && active?
  end

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Determines the locale set for the user or the organisation he/she belongs
  #
  # Returns String
  # Returns nil
  def locale
    if !language.nil?
      language.abbreviation
    elsif !org.nil?
      org.locale
    end
  end

  # Gives either the name of the user, or the email if name unspecified
  #
  # user_email - Use the email if there is no firstname or surname (defaults: true)
  #
  # Returns String
  # rubocop:disable Style/OptionalBooleanParameter
  def name(use_email = true)
    if (firstname.blank? && surname.blank?) || use_email
      email
    else
      name = "#{firstname} #{surname}"
      name.strip
    end
  end
  # rubocop:enable Style/OptionalBooleanParameter

  # The user's identifier for the specified scheme name
  #
  # scheme - The identifier scheme name (e.g. ORCID)
  #
  # Returns UserIdentifier
  def identifier_for(scheme)
    identifiers.by_scheme_name(scheme, 'User')&.first
  end

  # Checks if the user is a super admin. If the user has any privelege which requires
  # them to see the super admin page then they are a super admin.
  #
  # Returns Boolean
  def can_super_admin?
    can_add_orgs? || can_grant_api_to_orgs? || can_change_org?
  end

  # Checks if the user is an organisation admin if the user has any privlege which
  # requires them to see the org-admin pages then they are an org admin.
  #
  # Returns Boolean
  # rubocop:disable Metrics/CyclomaticComplexity
  def can_org_admin?
    return true if can_super_admin?

    # Automatically false if the user has no Org or the Org is not managed
    return false unless org.present? && org.managed?

    can_grant_permissions? || can_modify_guidance? ||
      can_modify_templates? || can_modify_org_details? ||
      can_review_plans?
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Can the User add new organisations?
  #
  # Returns Boolean
  def can_add_orgs?
    perms.include? Perm.add_orgs
  end

  # Can the User change their organisation affiliations?
  #
  # Returns Boolean
  def can_change_org?
    perms.include? Perm.change_affiliation
  end

  # Can the User can grant their permissions to others?
  #
  # Returns Boolean
  def can_grant_permissions?
    perms.include? Perm.grant_permissions
  end

  # Can the User modify organisation templates?
  #
  # Returns Boolean
  def can_modify_templates?
    perms.include? Perm.modify_templates
  end

  # Can the User modify organisation guidance?
  #
  # Returns Boolean
  def can_modify_guidance?
    perms.include? Perm.modify_guidance
  end

  # Can the User use the API?
  #
  # Returns Boolean
  def can_use_api?
    perms.include? Perm.use_api
  end

  # Can the User modify their org's details?
  #
  # Returns Boolean
  def can_modify_org_details?
    perms.include? Perm.change_org_details
  end

  ##
  # Can the User grant the api to organisations?
  #
  # Returns Boolean
  def can_grant_api_to_orgs?
    perms.include? Perm.grant_api
  end

  ##
  # Can the user review their organisation's plans?
  #
  # Returns Boolean
  def can_review_plans?
    perms.include? Perm.review_plans
  end

  # Removes the api_token from the user
  #
  # Returns nil
  # Returns Boolean
  def remove_token!
    return if new_record? || api_token.nil?

    update_column(:api_token, nil)
  end

  # Generates a new token for the user unless the user already has a token.
  #
  # Returns nil
  # Returns Boolean
  def keep_or_generate_token!
    return unless api_token.nil? || api_token.empty?

    generate_token! unless new_record?
  end

  # Generates a new token
  def generate_token!
    new_token = User.unique_random(field_name: 'api_token')
    update_column(:api_token, new_token)
  end

  # The User's preferences for a given base key
  #
  # Returns Hash
  # rubocop:disable Metrics/AbcSize
  def get_preferences(key)
    defaults = Pref.default_settings[key.to_sym] || Pref.default_settings[key.to_s]
    defaults = defaults.with_indifferent_access if defaults.present?

    if pref.present?
      existing = pref.settings[key.to_s].deep_symbolize_keys
      existing = existing.with_indifferent_access if existing.present?

      # Check for new preferences
      defaults.each_key do |grp|
        defaults[grp].each_key do |pref|
          # If the group isn't present in the saved values add all of it's preferences
          existing[grp] = defaults[grp] if existing[grp].nil?
          # If the preference isn't present in the saved values add the default
          existing[grp][pref] = defaults[grp][pref] if existing[grp][pref].nil?
        end
      end
      existing
    else
      defaults
    end
  end
  # rubocop:enable Metrics/AbcSize

  # Override to Devise invitation emails
  # def deliver_invitation(options = {})
  #   # Always override the devise_invitable email title
  #   super(options.merge(subject: _("A Data Management Plan in " \
  #     "%{application_name} has been shared with you") %
  #     { application_name: ApplicationService.application_name })
  #   )
  # end

  # Case insensitive search over User model
  #
  # field - The name of the field being queried
  # val   - The String to search for, case insensitive. val is duck typed to check
  #         whether or not downcase method exist.
  #
  # Returns ActiveRecord::Relation
  # Raises ArgumentError
  def self.where_case_insensitive(field, val)
    raise ArgumentError, "Field #{field} is not present on users table" unless columns.map(&:name).include?(field.to_s)

    User.where("LOWER(#{field}) = :value", value: val.to_s.downcase)
  end

  # Acknowledge a Notification
  #
  # notification - Notification to acknowledge
  #
  # Returns ActiveRecord::Associations::CollectionProxy
  # Returns nil
  def acknowledge(notification)
    notifications << notification if notification.dismissable?
  end

  # remove personal data from the user account and save
  # leave account in-place, with org for statistics (until we refactor those)
  #
  # Returns boolean
  # rubocop:disable Metrics/AbcSize
  def archive
    suffix = Rails.configuration.x.application.fetch(:archived_accounts_email_suffix, '@example.org')
    self.firstname = 'Deleted'
    self.surname = 'User'
    self.email = User.unique_random(field_name: 'email',
                                    prefix: 'user_',
                                    suffix: suffix,
                                    length: 5)
    self.recovery_email = nil
    self.api_token = nil
    self.encrypted_password = nil
    self.last_sign_in_ip = nil
    self.current_sign_in_ip = nil
    self.active = false
    save
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def merge(to_be_merged)
    scheme_ids = identifiers.pluck(:identifier_scheme_id)
    # merge logic
    # => answers -> map id
    to_be_merged.answers.update_all(user_id: id)
    # => notes -> map id
    to_be_merged.notes.update_all(user_id: id)
    # => plans -> map on id roles
    to_be_merged.roles.update_all(user_id: id)
    # => prefs -> Keep's from self
    # => auths -> map onto keep id only if keep does not have the identifier
    to_be_merged.identifiers
                .where.not(identifier_scheme_id: scheme_ids)
                .update_all(identifiable_id: id)
    # => ignore any perms the deleted user has
    to_be_merged.destroy
  end
  # rubocop:enable Metrics/AbcSize

  private

  # ============================
  # = Private instance methods =
  # ============================

  def delete_perms!
    perms.destroy_all
  end

  def clear_department_id
    self.department_id = nil
  end
end
