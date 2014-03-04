class User < ActiveRecord::Base
  has_secure_password
  before_save { email.downcase! }

  validates :name, :email, presence: true
  validates :name, length: { maximum: 20, minimum: 4 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }	
 
end
