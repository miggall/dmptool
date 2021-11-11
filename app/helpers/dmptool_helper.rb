# frozen_string_literal: true

# DMPTool specific helpers
module DmptoolHelper
  # Converts some of the language of User validation errors
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def auth_has_error?(attribute)
    return false unless attribute.present? && resource.present? &&
                        resource.errors.present? && resource.errors.any?

    errs = resource.errors.full_messages

    case attribute.to_sym
    when :org, :org_id
      errs.select { |err| err.start_with?('Institution') }.any?
    when :accept_terms
      errs.select { |err| err.include?('the terms') }.any?
    else
      errs.select { |err| err.start_with?(attribute.to_s.humanize) }.any?
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Determine which UI template we should use based on the page
  def page_body_template
    template = 't-generic'
    template = 't-home' if active_page?(root_path, true) ||
                           active_page?(new_user_session_path, true) ||
                           active_page?(new_user_registration_path, true) ||
                           active_page?(user_registration_path, true) ||
                           active_page?(new_user_password_path, true)
    template
  end

  # Bacckground images for the home page
  def hero_images
    %w[1-large.jpg 2-large.jpg 3-large.jpg 4-large.jpg 5-large.jpg]
  end

  # Collect general statistics about the application
  def statistics
    cached = Rails.cache.read('stats')
    return cached unless cached.nil?

    stats = {
      user_count: User.select(:id).count,
      completed_plan_count: Plan.select(:id).count,
      institution_count: Org.participating.select(:id).count
    }
    cache_content('stats', stats)
    stats
  end

  # Collect  the list of the top 5 most used templates for the past 90 days
  def top_templates
    cached = Rails.cache.read('top_five')
    return cached unless cached.nil?

    end_date = Date.today
    start_date = (end_date - 90)
    ids = Plan.group(:template_id)
              .where(created_at: start_date..end_date)
              .order('count_id DESC')
              .count(:id).keys

    top_five = Template.where(id: ids[0..4])
                       .pluck(:title)
    cache_content('top_five', top_five)
    top_five
  end

  # Get the last 5 blog posts
  def feed
    cached = Rails.cache.read('rss')
    return cached unless cached.nil?

    resp = HTTParty.get(Rails.configuration.x.application.blog_rss)
    return [] unless resp.code == 200

    rss = RSS::Parser.parse(resp.body, false).items.first(5)
    cache_content('rss', rss)
    rss
  rescue StandardError => e
    # If we were unable to connect to the blog rss
    logger.error("Caught exception RSS parse: #{e}.")
    []
  end

  # Store information in the cache
  def cache_content(type, data)
    return nil unless type.present?

    Rails.cache.write(type, data, expires_in: 60.minutes)
  rescue StandardError => e
    logger.error("Unable to add #{type} to the Rails cache: #{e}.")
  end
end
