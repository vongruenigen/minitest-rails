# Make double-sure the RAILS_ENV is not set to production,
# so fixtures aren't loaded into that environment
abort("Abort testing: Your Rails environment is running in production mode!") if Rails.env.production?

require "minitest/rails/active_support"
require "minitest/rails/action_controller"
require "minitest/rails/action_view"
require "minitest/rails/action_mailer" if defined? ActionMailer
require "minitest/rails/action_dispatch"

# Enable turn if it is available
begin
  require 'turn/autorun'
rescue LoadError
end

module MiniTest
  module Rails
    ##
    # Replaces the default tests with the ones from minitest-rails.
    # This allows you to drop the 'MiniTest::Rails::' namespace
    # from your tests, and use minitest-rails in your existing
    # Test::Unit tests.
    def self.override_testunit!
      Kernel.silence_warnings do
        ::ActiveSupport.const_set    :TestCase,        MiniTest::Rails::ActiveSupport::TestCase
        ::ActionController.const_set :TestCase,        MiniTest::Rails::ActionController::TestCase
        ::ActionView.const_set       :TestCase,        MiniTest::Rails::ActionView::TestCase
        ::ActionMailer.const_set     :TestCase,        MiniTest::Rails::ActionMailer::TestCase if defined? ActionMailer
        ::ActionDispatch.const_set   :IntegrationTest, MiniTest::Rails::ActionDispatch::IntegrationTest
      end
    end
    ##
    # Force all tests using the spec DSL to use ActiveSupport::TestCase.
    # This is useful if you are testing objects that do not inherit
    # from the classes Rails provides (ActiveRecord, ActiveMailer, etc.)
    # but you still want db transactions and fixtures in your tests.
    def self.override_default_spec!
      MiniTest::Spec::TYPES.last[1] = MiniTest::Rails::ActiveSupport::TestCase
    end
  end
end

if defined?(ActiveRecord::Base)
  class MiniTest::Rails::ActiveSupport::TestCase
    include ActiveRecord::TestFixtures
    self.fixture_path = "#{Rails.root}/test/fixtures/"
  end

  MiniTest::Rails::ActionDispatch::IntegrationTest.fixture_path = MiniTest::Rails::ActiveSupport::TestCase.fixture_path

  def create_fixtures(*table_names, &block)
    ActiveRecord::Fixtures.create_fixtures(MiniTest::Rails::ActiveSupport::TestCase.fixture_path, table_names, {}, &block)
  end
end

class MiniTest::Rails::ActionController::TestCase
  setup do
    @routes = Rails.application.routes
  end
end

class MiniTest::Rails::ActionDispatch::IntegrationTest
  setup do
    @routes = Rails.application.routes
  end
end
