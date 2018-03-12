class ApplicationRecord < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
