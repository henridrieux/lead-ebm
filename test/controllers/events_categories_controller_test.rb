require 'test_helper'

class EventsCategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get events_categories_index_url
    assert_response :success
  end

  test "should get show" do
    get events_categories_show_url
    assert_response :success
  end

end
