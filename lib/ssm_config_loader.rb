# frozen_string_literal: true

require 'uc3-ssm'

class SsmConfigLoader < Anyway::Loaders::Base
  def initialize(local:)
    # Need a check here to see if Uc3Ssm could be initialized
    # @ssm = Uc3Ssm::ConfigResolver.new
    super(local: local)
  end

  def call(name:, **_opts)
    # We can define default SSM values here and then call out to SSM via Terry's SSM gem
    hash = {
      dmptool: {
        # secret_key_base: fetch_ssm_value(key: SECRET_KEY_BASE) || "12345",
        roses: "red",
        violets: "blue"
      }
    }.with_indifferent_access

    trace!(source: :ssm) do
      hash[name].to_h || {}
    end
  end

  private

  # Fetch the specified value from SSM
  def fetch_ssm_value(key:)
    return nil unless key.present? && @ssm.present?

    # master_key = @ssm.parameter_for_key(key)
    nil
  end
end