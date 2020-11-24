require 'test_helper'

class RecruitmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get recruitments_index_url
    assert_response :success
  end

  test "should get show" do
    get recruitments_show_url
    assert_response :success
  end

end
