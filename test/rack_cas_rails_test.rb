require 'test_helper'

class RackCASRailsTest < ActiveSupport::TestCase

  APP_CONTROLLER_METHODS = %w(
    authenticate!
    authenticated?
    login_url
    logout_url
  )

  test "truth" do
    assert_kind_of Module, RackCASRails
  end

  test "application controller has new methods" do
      APP_CONTROLLER_METHODS.each do |method|
      assert ApplicationController.method_defined?(method.to_sym)
    end
  end

  test "helpers defined" do
      APP_CONTROLLER_METHODS.each do |method|
      assert ApplicationController._helper_methods.include?(method.to_sym)
    end
  end

end
