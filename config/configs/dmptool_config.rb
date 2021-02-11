# frozen_string_literal: true

class DmptoolConfig < Anyway::Config
  attr_config :excellence,         # Located in ENV variable
              :dmphub_url,         # Located in DOTENV (.env) file
              :recaptcha_site_key, # Located in credentials.yml.enc
              :recaptcha,          # Located in credentials.yml.enc
              :big,                # Located in config/dmptool.yml
              :roses,              # Located in SSM (loaded via lib/ssm_config_loader.rb)
              :org_name,
              :db_adapter

  def foo
    "bar"
  end
end
