class Circle < ActiveRecord::Base 
  has_many :books
  has_many :users
  has_many :authors
end