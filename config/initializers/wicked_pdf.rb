# frozen_string_literal: true

module DMPRoadmap

  class Application < Rails::Application

    WickedPdf.config = {
      exe_path: Rails.root.join("bin", "wkhtmltopdf").to_s # /dmp/local/bin/wkhtmltopdf"
    }

  end

end
