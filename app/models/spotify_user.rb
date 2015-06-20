class SpotifyUser < ActiveRecord::Base
  has_many :user_sessions
  has_and_belongs_to_many :sessions, class_name: "Session", join_table: 'users_sessions', foreign_key: 'spotify_id',
          association_foreign_key: 'session_id'

  validates :id, presence: true, uniqueness: true
  serialize :rspotify_hash, Hash
end