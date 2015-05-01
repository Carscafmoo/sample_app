class User < ActiveRecord::Base
  before_save do 
    self.email.downcase! #! modifies in place
  end 
  validates :name, {presence: true, length: {maximum: 50}} 
  validates :email, {presence: true, 
                      length: {maximum: 255}, 
                      format: {with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i},
                      uniqueness: {case_sensitive: false}}
  validates :password, length: {minimum: 5} # BECAUSE WE'RE CRAZY
  has_secure_password
end
