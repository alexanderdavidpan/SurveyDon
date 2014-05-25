require 'bcrypt'

class User < ActiveRecord::Base
  # users.password_hash in the database is a :string
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  validates :username, uniqueness: true

  has_many :surveys

  has_many :surveyed_users
  has_many :responses, through: :surveyed_users
end
