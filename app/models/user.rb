class User < ActiveRecord::Base
  validates :spotify_id, presence: true, uniqueness: true
end
