# frozen_string_literal: true

require 'uc3-ssm'
require 'logger'
require 'pp'
require "anyway/utils/deep_merge"

$logger = Logger.new(STDOUT)
class SsmConfigLoader < Anyway::Loaders::Base


  def call(name:, **_opts)
    resolver = Uc3Ssm::ConfigResolver.new(ssm_root_path: '/uc3/dmp/tool/stg:/uc3/dmp/tool/default')
    #@ssm = Uc3Ssm::ConfigResolver.new(ssm_root_path: '/uc3/dmp/tool/stg')
    parameters = resolver.parameters_for_path(path: name)
    #pp parameters

    config = {}

    ## # Anyway::Utils.deep_merge gives presidence to last matching key,
    ## # so I reverse the processing order of parameters list.
    ## parameters.reverse_each do |param|
    ##   # strip off ssm_root_path
    ##   sub_path = name + param[:name].partition(name)[-1]
    ##   #pp sub_path
    ##   pp param[:name]
    
    ##   # convert elements of sub_path into hash keys recursively
    ##   new_hash = hashify_param_path({}, sub_path, param[:value])
    ##   #pp new_hash
    ##   Anyway::Utils.deep_merge!(config, new_hash)
    ## end
    ## pp config
    ## puts
    
    #trace!(:ssm_parameter_store, ssm_root_path: "#{ENV['SSM_ROOT_PATH']}") do
    trace!(:ssm_parameter_store, ssm_root_path: "SSM_ROOT_PATH") do
      parameters.reverse_each do |param|
        sub_path = name + param[:name].partition(name)[-1] # strip off ssm_root_path
        new_hash = hashify_param_path({}, sub_path, param[:value])
        Anyway::Utils.deep_merge!(config, new_hash)
      end
    end

    pp config
    config

  rescue Uc3Ssm::ConfigResolverError => e
    $logger.warn("#{e.message}")
    return {}

  end

  def hashify_param_path(new_hash, path, value)
    key, x, sub_path = path.partition('/')
    if sub_path.empty?
      new_hash[key] = value
    else
      new_hash[key] = hashify_param_path({}, sub_path, value)
    end
    return new_hash
  end

end