REPL_SLUG=ENV['REPL_SLUG']
REPL_OWNER=ENV['REPL_OWNER']
REPL_ID=ENV['REPL_ID']

require "bundler/inline"

gemfile true do
  source "https://rubygems.org"
  gem "rails", "~> 6.1.3"
  gem "puma", "~> 5.2.2"
  gem "pry"
end

require "action_controller/railtie"
require "rails/command"
require "rails/commands/server/server_command"

class ApplicationController < ActionController::Base
  prepend_view_path 'app/views'
end

class DemosController < ApplicationController
  def show
    render :show
  end
end

class MiniApp < Rails::Application
  config.action_controller.perform_caching = true
  config.consider_all_requests_local = true
  config.public_file_server.enabled = true
  config.secret_key_base = "cde22ece34fdd96d8c72ab3e5c17ac86"
  config.secret_token = "bf56dfbbe596131bfca591d1d9ed2021"
  config.session_store :cookie_store
  config.hosts << "#{REPL_SLUG}.#{REPL_OWNER}.repl.co"
  config.hosts << "#{REPL_ID}.id.repl.co"

  Rails.logger = Logger.new($stdout)

  routes.draw do
    resource :demo, only: :show
    root "demos#show"
  end
end

if RUBY_VERSION.to_f > 2.5 
  system "yarn && yarn build", exception: true
else
  system "yarn && yarn build"
end

Rails::Server.new(app: MiniApp, Host: "0.0.0.0", Port: 8080).start
