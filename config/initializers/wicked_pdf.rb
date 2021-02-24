# frozen_string_literal: true

module DMPRoadmap

  class Application < Rails::Application

    WickedPdf.config = {
      exe_path: Rails.configuration.x.system.wkhtmltopdf_path
    }

  end

end
