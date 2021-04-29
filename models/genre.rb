class Genre < ActiveRecord::Base
  has_many :book_genres, dependent: :destroy
  has_many :books, through: :book_genres
end