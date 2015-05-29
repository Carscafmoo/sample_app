require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new({name: "Carson Moore", email: "Carscafmoo@gmail.com", password: 'guest', password_confirmation: 'guest'})
  end

  test "User is valid" do
    assert @user.valid?    
  end

  test "Name is required" do
    @user.name = "     "
    assert_not @user.valid?
  end

    test "Email is required" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "Name cannot be too long" do
    @user.name = "a" * 51 # max 50
    assert_not @user.valid?
  end

  test "Email cannot be too long" do 
    @user.email = "a"*244 + "@example.com" # results in 256
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    duplicate_user.email = duplicate_user.email.upcase; # need to test for case-insensitive uniqueness 
    assert_not duplicate_user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 4
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

end