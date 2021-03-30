# frozen_string_literal: true

# == Schema Information
#
# Table name: api_clients
#
#  id             :integer          not null, primary key
#  name           :string,          not null
#  homepage       :string
#  contact_name   :string
#  contact_email  :string,          not null
#  client_id      :string,          not null
#  client_secret  :string,          not null
#  last_access    :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#
# Indexes
#
#  index_api_clients_on_name     (name)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)

class ApiClient < ApplicationRecord

  self.table_name = "oauth_applications"

  include DeviseInvitable::Inviter
  include Subscribable
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application

  extend UniqueRandom

  # ================
  # = Associations =
  # ================

  belongs_to :org, optional: true

  has_many :plans

  has_many :access_tokens, class_name: '::Doorkeeper::AccessToken',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { case_sensitive: false,
                                 message: UNIQUENESS_MESSAGE }

  validates :contact_email, presence: { message: PRESENCE_MESSAGE },
                            email: { allow_nil: false }

  # =================
  # = Compatibility =
  # =================

  alias_attribute :client_id, :uid
  alias_attribute :client_secret, :secret

  deprecate :client_id, deprecator: Cleanup::Deprecators::GetDeprecator.new
  deprecate :client_secret, deprecator: Cleanup::Deprecators::GetDeprecator.new

  # =========================
  # = Custom Accessor Logic =
  # =========================

  # Ensure the name is always saved as lowercase
  # TODO: do we want to add this as a validation as well?
  def name=(value)
    super(value&.downcase)
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # Override the to_s method to keep the id and secret hidden
  def to_s
    name
  end

  # Verify that the incoming secret matches
  def authenticate(secret:)
    ActiveSupport::Deprecation.warn(
      "ApiClient.authenticate is only applicable to API V1. It is replaced by Doorkeeper methods."
    )
    client_secret == secret
  end

end
