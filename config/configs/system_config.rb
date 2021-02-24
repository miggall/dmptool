# frozen_string_literal: true

class SystemConfig < Anyway::Config
  attr_config :secret_key_base,
              :server_host,
              :port,
              :cookie_key,
              :web_concurrency,

              :rails_log_to_stdout,
              :rails_max_threads,
              :rails_serve_static_files,

              :cache_org_selection_expiration,
              :cache_research_projects_expiration,

              :database_adapter,
              :database_name,
              :database_pool_size,
              :database_host,
              :database_username,
              :database_password,

              :devise_pepper,

              :dragonfly_aws,
              :dragonfly_bucket,
              :dragonfly_host,
              :dragonfly_root_path,
              :dragonfly_secret,
              :dragonfly_url_scheme,

              # External API config settings
              #-----------------------------
              :doi_minting,

              :dmphub_active,
              :dmphub_url,
              :dmphub_client_id,
              :dmphub_client_secret,

              :google_analytics_tracker_root,

              :openaire_active,

              :orcid_client_id,
              :orcid_client_secret,
              :orcid_sandbox,

              :recaptcha_enabled,
              :recaptcha_site_key,
              :recaptcha_secret_key,

              :rollbar_env,
              :rollbar_access_token,

              :ror_active,

              :shibboleth_enabled,
              :shibboleth_login_url,
              :shibboleth_logout_url,
              :shibboleth_use_filtered_discovery_service,

              :translation_io_key,

              :usersnap_key,

              :wkhtmltopdf_path

  required :secret_key_base, :server_host, :port, :cookie_key,
           :database_adapter, :database_host, :database_username,
           :devise_pepper,
           :doi_minting,
           :orcid_client_id, :orcid_client_secret, :orcid_sandbox,
           :recaptcha_enabled,
           :shibboleth_enabled,
           :wkhtmltopdf_path
end
