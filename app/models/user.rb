class User < ActiveRecord::Base
  attr_accessor :remember_token # sets up get/set on remember_token via user_instance.rememberToken (=...)
  before_save do 
    self.email = email.downcase
  end 
  validates :name, {presence: true, length: {maximum: 50}} 
  validates :email, {presence: true, 
                      length: {maximum: 255}, 
                      format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
                      uniqueness: {case_sensitive: false}}
  validates :password, length: {minimum: 5} # BECAUSE WE'RE CRAZY
  has_secure_password

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token)) #self is implied before remember_token
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
