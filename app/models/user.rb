class User < ActiveRecord::Base
  validates :name, presence: true
  validates :image, presence: true
  validates :spotify_id, uniqueness: true
end
