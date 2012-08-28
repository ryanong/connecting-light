require "minitest_helper"

describe VizController do
  it "should get map" do
    get :map
    assert_response :success
  end

end
