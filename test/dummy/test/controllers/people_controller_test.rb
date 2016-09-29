require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  fixtures :all

  setup do
    @person = people(:one)
  end

  test "should get success for index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:people)
    RackCASRailsTest::APP_CONTROLLER_METHODS.each do |method|
      assert @controller.methods.include?(method.to_sym)
    end
  end

  test "should get unauthorized for new" do
    # should get :unauthorized because of the before_action in PeopleController
    # that says:
    #   before_action :authenticate! except: [:index, :show]
    get :new
    assert_response :unauthorized
  end

  # test "should create person" do
  #   assert_difference('Person.count') do
  #     post :create, person: { age: @person.age, name: @person.name }
  #   end

  #   assert_redirected_to person_path(assigns(:person))
  # end

  test "should get success for show" do
    get :show, params: { id: @person.id }
    assert_response :success
  end

  # test "should get edit" do
  #   get :edit, id: @person
  #   assert_response :success
  # end

  # test "should update person" do
  #   patch :update, id: @person, person: { age: @person.age, name: @person.name }
  #   assert_redirected_to person_path(assigns(:person))
  # end

  # test "should destroy person" do
  #   assert_difference('Person.count', -1) do
  #     delete :destroy, id: @person
  #   end

  #   assert_redirected_to people_path
  # end
end
