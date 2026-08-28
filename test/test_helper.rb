ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Hoop Helix is not using a database so fixtures are not needed. If you add a database in the future, uncomment the following line to enable fixtures.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
