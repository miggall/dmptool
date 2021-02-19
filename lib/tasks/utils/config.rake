# frozen_string_literal: true

require "text"

# rubocop:disable Metrics/BlockLength
namespace :config do

  desc "Determine where all of the local config values are coming from"
  task trace: :environment do
    [SystemConfig.new, ApplicationConfig.new].each do |config|
      p "Loading #{config.class.name}:"
      p "---------------------------------------------------"
      p ""
      pp config.to_source_trace
      p ""
      p "==================================================="
      p "==================================================="
      p ""
    end
  end

end
