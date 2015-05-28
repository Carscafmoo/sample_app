class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token # sets up get/set on tokens via user_instance.rememberToken (=...)
  before_save :downcase_email 
  before_create :create_activation_digest
  validates :name, {presence: true, length: {maximum: 50}} 
  validates :email, {presence: true, 
                      length: {maximum: 255}, 
                      format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
                      uniqueness: {case_sensitive: false}}
  validates :password, length: {minimum: 5}, allow_blank: true # BECAUSE WE'RE CRAZY

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
  def authenticated?(attribute, token)
    digest = self["#{attribute}_digest"] # self.send also works but I don't see why we'd use that over this accessor?
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_token
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private
    def downcase_email
      self.email = email.downcase
    end
    
    def create_activation_digest 
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token) # see above about self
    end
end
