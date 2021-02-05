# rubocop:disable Naming/FileName
# frozen_string_literal: true

server 'localhost', user: fetch(:user), roles: %w[web app db]

# Define the location of the private configuration repo
#set :config_branch, "uc3-dmpx2-prd"

