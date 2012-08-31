require "minitest_helper"

describe LogsController do

  before do
    @log = Log.new
  end

  it "must get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:logs)
  end

  it "must get new" do
    get :new
    assert_response :success
  end

  it "must create log" do
    assert_difference('Log.count') do
      post :create, log: @log.attributes
    end

    assert_redirected_to log_path(assigns(:log))
  end

  it "must show log" do
    get :show, id: @log.to_param
    assert_response :success
  end

  it "must get edit" do
    get :edit, id: @log.to_param
    assert_response :success
  end

  it "must update log" do
    put :update, id: @log.to_param, log: @log.attributes
    assert_redirected_to log_path(assigns(:log))
  end

  it "must destroy log" do
    assert_difference('Log.count', -1) do
      delete :destroy, id: @log.to_param
    end

    assert_redirected_to logs_path
  end

end
