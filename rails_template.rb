require 'active_support/core_ext/array/wrap'

#####################################################
# Application Generator Template
# Usage: rails new APP_NAME -d mysql -T -m https://raw.github.com/tonycoco/rails_template/master/rails_template.rb
#
# If you are customizing this template, you can use any methods provided by Thor::Actions
# http://rubydoc.info/github/wycats/thor/master/Thor/Actions
# and Rails::Generators::Actions
# http://github.com/rails/rails/blob/master/railties/lib/rails/generators/actions.rb
#####################################################

#####################################################
# Gems
#####################################################
gem 'bootstrap-sass'
gem 'bootstrap_kaminari', :git => 'git://github.com/dleavitt/bootstrap_kaminari.git'
gem 'cancan'
gem 'carrierwave'
gem 'devise'
gem 'fog'
gem 'haml-rails'
gem 'kaminari'
gem 'mini_magick'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'resque', :require => 'resque/server'
gem 'settingslogic'
gem 'simple_form'

gem_group :development do
  gem 'capistrano'
  gem 'debugger'
  gem 'foreman'
  gem 'taps'
end

gem_group :development, :test do
  gem 'mysql2'
  gem 'rspec-rails'
  gem 'syntax'
end

gem_group :test do
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
end

gem_group :production do
  gem 'pg'
  gem 'thin'
end

#####################################################
# Bundle
#####################################################
run 'bundle install'
rake 'db:create'
rake 'db:migrate'

#####################################################
# SettingsLogic
#####################################################
get 'https://raw.github.com/tonycoco/rails_template/master/files/settings_logic/config.yml', 'config/application.yml'
get 'https://raw.github.com/tonycoco/rails_template/master/files/settings_logic/model.rb', 'app/models/settings.rb'

#####################################################
# ApplicationHelper
#####################################################
get 'https://raw.github.com/tonycoco/rails_template/master/files/lib/bootstrap_helper.rb', 'app/helpers/bootstrap_helper.rb'

inject_into_file 'app/helpers/application_helper.rb', :before => 'end' do <<-RUBY
  include BootstrapHelper
RUBY
end

#####################################################
# Locales
#####################################################
gsub_file 'config/locales/en.yml', /  hello: "Hello world"/ do <<-YAML
  application:
    name: "CHANGEME"
    slogan: "CHANGEME"
  alerts:
    headings:
      default: "Heads up!"
      alert: "Oh snap!"
      notice: "Well done!"
YAML
end

#####################################################
# Application Layout
#####################################################
remove_file 'app/views/layouts/application.html.erb'
get 'https://raw.github.com/tonycoco/rails_template/master/files/views/layouts/application.html.haml', 'app/views/layouts/application.html.haml'
get 'https://raw.github.com/tonycoco/rails_template/master/files/views/shared/_navbar.html.haml', 'app/views/shared/_navbar.html.haml'
remove_file 'app/assets/javascripts/application.js'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/javascripts/application.js', 'app/assets/javascripts/application.js'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/javascripts/jquery.validate.js', 'app/assets/javascripts/jquery.validate.js'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/javascripts/jquery.validate.bootstrap.js', 'app/assets/javascripts/jquery.validate.bootstrap.js'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/stylesheets/layout.css.scss', 'app/assets/stylesheets/layout.css.scss'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/stylesheets/_overrides.css.scss', 'app/assets/stylesheets/_overrides.css.scss'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/stylesheets/_shared.css.scss', 'app/assets/stylesheets/_shared.css.scss'

#####################################################
# Heroku
#####################################################
get 'https://raw.github.com/tonycoco/rails_template/master/files/heroku/Procfile', 'Procfile'

#####################################################
# RSpec
#####################################################
generate 'rspec:install'
run 'rm -rf test'

application do <<-RUBY
config.generators do |g|
      g.view_specs false
      g.helper_specs false
      g.template_engine :haml
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
RUBY
end

inject_into_file 'spec/spec_helper.rb', :before => 'end' do <<-RUBY
  require 'database_cleaner'

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
RUBY
end

#####################################################
# Cucumber
#####################################################
generate 'cucumber:install --capybara --rspec'

#####################################################
# Carrierwave
#####################################################
get 'https://raw.github.com/tonycoco/rails_template/master/files/carrierwave/avatar_uploader.rb', 'app/uploaders/avatar_uploader.rb'
get 'https://raw.github.com/tonycoco/rails_template/master/files/carrierwave/avatar.png', 'app/assets/images/avatar.png'
get 'https://raw.github.com/tonycoco/rails_template/master/files/carrierwave/initializer.rb', 'config/initializers/carrierwave.rb'
get 'https://raw.github.com/tonycoco/rails_template/master/files/carrierwave/aws.rake', 'lib/tasks/aws.rake'

#####################################################
# SimpleForm
#####################################################
generate 'simple_form:install --bootstrap'
get 'https://raw.github.com/tonycoco/rails_template/master/files/simple_form/image_preview_input.rb', 'app/inputs/image_preview_input.rb'

#####################################################
# Devise
#####################################################
generate 'devise:install'
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'
generate 'devise user'
generate 'migration', 'AddExtrasToUsers role:string avatar:string data:binary'
gsub_file 'app/models/user.rb', /:validatable/, ':validatable, :omniauthable'
gsub_file 'app/models/user.rb', /:remember_me/, ':remember_me, :role, :data, :avatar, :avatar_cache, :remove_avatar, :remote_avatar_url'

gsub_file 'config/routes.rb', /  devise_for :users/ do <<-RUBY
  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }

  devise_scope :users do
    get 'users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end
RUBY
end

inject_into_file 'app/controllers/application_controller.rb', :after => "  protect_from_forgery\n" do <<-RUBY
  before_filter :authenticate_user!
RUBY
end

inject_into_file 'config/initializers/devise.rb', :after => "Devise.setup do |config|\n" do <<-RUBY
  config.omniauth :facebook, Settings.facebook.app_id, Settings.facebook.app_secret, :scope => 'email,publish_actions'
RUBY
end

gsub_file 'config/initializers/devise.rb', /please-change-me-at-config-initializers-devise@example.com/, 'CHANGEME@example.com'

inject_into_file 'app/models/user.rb', :before => 'end' do <<-RUBY

  serialize :data

  mount_uploader :avatar, AvatarUploader

  after_create :user_created

  class << self
    def find_for_facebook_oauth(access_token, signed_in_resource=nil)
      if user = User.where(:email => access_token.info.email).first
        user
      else
        User.create!(:email => access_token.info.email, :password => Devise.friendly_token[0, 20], :data => { :facebook => access_token })
      end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
          user.email = data['email']
        end
      end
    end
  end

  protected

  def user_created
    Resque.enqueue(UserWorker, :save_avatar, 'user_id' => id)
  end
RUBY
end

get 'https://raw.github.com/tonycoco/rails_template/master/files/devise/omniauth_callbacks_controller.rb', 'app/controllers/users/omniauth_callbacks_controller.rb'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/stylesheets/_registrations.css.scss', 'app/assets/stylesheets/_registrations.css.scss'

inside 'app/views/devise' do
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/confirmations/new.html.haml', 'confirmations/new.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/mailer/confirmation_instructions.html.haml', 'mailer/confirmation_instructions.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/mailer/reset_password_instructions.html.haml', 'mailer/reset_password_instructions.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/mailer/unlock_instructions.html.haml', 'mailer/unlock_instructions.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/passwords/edit.html.haml', 'passwords/edit.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/passwords/new.html.haml', 'passwords/new.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/registrations/edit.html.haml', 'registrations/edit.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/registrations/new.html.haml', 'registrations/new.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/sessions/new.html.haml', 'sessions/new.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/_links.html.haml', '_links.html.haml'
  get 'https://raw.github.com/tonycoco/rails_template/master/files/views/devise/unlocks/new.html.haml', 'unlocks/new.html.haml'
end

create_file 'spec/support/devise.rb' do <<-RUBY
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
RUBY
end

#####################################################
# CanCan
#####################################################
generate 'cancan:ability'

#####################################################
# Welcome and Dashboard
#####################################################
generate(:controller, 'welcome', '--skip-assets')

inject_into_file 'app/controllers/welcome_controller.rb', :before => 'end' do <<-RUBY
  skip_before_filter :authenticate_user!, :only => :index

  def index
    redirect_to dashboard_path if user_signed_in?

    @user = User.new
  end
RUBY
end

route "root :to => 'welcome#index'"
get 'https://raw.github.com/tonycoco/rails_template/master/files/views/welcome/index.html.haml', 'app/views/welcome/index.html.haml'
get 'https://raw.github.com/tonycoco/rails_template/master/files/assets/stylesheets/_welcome.css.scss', 'app/assets/stylesheets/_welcome.css.scss'

generate(:controller, 'dashboard', '--skip-assets')
route "match 'dashboard' => 'dashboard#index', :as => :dashboard"
get 'https://raw.github.com/tonycoco/rails_template/master/files/views/dashboard/index.html.haml', 'app/views/dashboard/index.html.haml'
gsub_file 'app/assets/stylesheets/application.css', '*= require_tree .', '*= require layout'

#####################################################
# Redis
#####################################################
route "mount Resque::Server.new, :at => '/resque'"

append_file 'Rakefile' do <<-RUBY
require 'resque/tasks'
RUBY
end

get 'https://raw.github.com/tonycoco/rails_template/master/files/resque/user_worker.rb', 'app/workers/user_worker.rb'
get 'https://raw.github.com/tonycoco/rails_template/master/files/resque/initializer.rb', 'config/initializers/resque.rb'

#####################################################
# Clean-up
#####################################################
%w{
  README
  doc/README_FOR_APP
  public/index.html
  app/assets/images/rails.png
}.each { |file| remove_file file }

#####################################################
# Robots
#####################################################
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'

#####################################################
# Git
#####################################################
append_file '.gitignore' do <<-GIT
/public/system
/public/uploads
/coverage
rerun.txt
.rspec
capybara-*.html
.DS_Store
.rbenv-vars
.rbenv-version
GIT
end

rake 'db:migrate'

git :init
git :add => '.'
git :commit => '-aqm "initial commit"'
