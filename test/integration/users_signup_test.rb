require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
    assert_select 'div.alert.alert-danger', {text: "The form contains 4 errors."}
    assert_select '#error_explanation ul li', {count: 4}
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name:  "Example User",
                               email: "user@example.com",
                               password:              "guest",
                               password_confirmation: "guest" }
    end
    assert_template 'users/show'
    assert_select ".alert.alert-success", {count: 1}
    assert is_logged_in?
  end
end