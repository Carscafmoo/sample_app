require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:guest)
  end

  test "Flash persistence on failed login" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: {email: 'boodliboo', password: 'notright'}
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "Login works" do
    get login_path
    # template already asserted
    # seems like there should be a test for login being in the header here so I'ma add it even though it's not in them examples
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    post login_path, session: {email: @user.email, password: 'guest'} ## why not post_via_redirect or whatever?
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path #simulates clicking logout again in another window
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end


  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end