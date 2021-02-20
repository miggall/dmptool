# frozen_string_literal: true

require 'uc3-ssm'
require 'logger'
require 'pp'

$logger = Logger.new(STDOUT)
class SsmConfigLoader < Anyway::Loaders::Base


  def call(name:, **_opts)
    config = {}
    @ssm = Uc3Ssm::ConfigResolver.new(ssm_root_path: '/uc3/dmp/tool/stg:/uc3/dmp/tool/default')
    #@ssm = Uc3Ssm::ConfigResolver.new(ssm_root_path: '/uc3/dmp/tool/stg')
    #value = @ssm.parameter_for_key(name)
    parameters = @ssm.parameters_for_path(path: name)
    parameters.each do |p|
      k = p.name.split('/')[-1] 
      config[k] = p.value unless config.has_key?(k)
    end
    pp config
    
  rescue Uc3Ssm::ConfigResolverError => e
    $logger.warn("#{e.message}")
    return {}

    return {} if value == key # ssm_skip_resolution is true

    trace!(source: :ssm, store: "SSM_ROOT_PATH=#{ENV['SSM_ROOT_PATH']}") do
      config
    end
    config
  end
end