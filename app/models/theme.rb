# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  description :text(65535)
#  locale      :string(255)
#  title       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Object that represents a question/guidance theme
class Theme < ApplicationRecord
  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :questions, join_table: 'questions_themes'
  has_and_belongs_to_many :guidances, join_table: 'themes_in_guidance'

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(title) LIKE lower(?) OR description LIKE lower(?)',
          search_pattern, search_pattern)
  }

  # ===========================
  # = Public instance methods =
  # ===========================

  # The title of the Theme
  #
  # Returns String
  def to_s
    title
  end
end
