# frozen_string_literal: true

class ApplicationConfig < Anyway::Config
  attr_config :name,
              :do_not_reply_email,
              :helpdesk_email,
              :organisation_name,
              :organisation_abbreviation,
              :organisation_url,
              :organisation_copywrite_name,
              :email_from_address,
              :organisation_phone,
              :organisation_address_line1,
              :organisation_address_line2,
              :organisation_address_line3,
              :organisation_address_line4,
              :organisation_country,
              :organisation_google_maps_link,

              :archived_accounts_email_suffix,
              :contact_us_url,
              :csv_separators,
              :api_max_page_size,
              :api_documentation_urls,
              :release_notes_url,
              :issue_list_url,
              :user_group_subscription_url,
              :blog_rss,
              :welcome_links,

              :locales_default,
              :locales_i18n_join_character,
              :locales_gettext_join_character,

              :preferences,

              :max_number_links_funder,
              :max_number_links_org,
              :max_number_links_sample_plan,
              :max_number_themes_per_column,
              :results_per_page,

              :plans_default_visibility,
              :plans_default_percentage_answered,
              :plans_org_admins_read_all,
              :plans_super_admins_read_all,
              :preferred_licenses,
              :preferred_licenses_guidance_url

  required :name, :do_not_reply_email, :helpdesk_email, :organisation_name,
           :welcome_links, :locales_default, :preferences,
           :max_number_links_funder, :max_number_links_org,
           :max_number_links_sample_plan, :max_number_themes_per_column,
           :plans_default_visibility, :plans_default_percentage_answered, :plans_org_admins_read_all,
           :plans_super_admins_read_all
end
