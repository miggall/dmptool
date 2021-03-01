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
      #pp "master_key: #{ENV['RAILS_MASTER_KEY']}"
      #pp "secret_key_base: #{Rails.application.credentials.system[:secret_key_base]}"
      pp config.to_source_trace
      p ""
      p "==================================================="
      p "==================================================="
      p ""
    end
  end

  desc "Dump rails configs which were discovered by Anyway::Config classes"
  task dump: :environment do
      p "Dumping config.x.system:"
      p "---------------------------------------------------"
      pp Rails.application.config.x.system
      p ""
      p "Dumping config.x.application:"
      p "---------------------------------------------------"
      pp Rails.application.config.x.application
      p ""
  end

end
