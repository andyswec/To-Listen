class SpotifyUser < ActiveRecord::Base
  has_many :user_sessions
  has_and_belongs_to_many :sessions, class_name: "Session", join_table: 'users_sessions', foreign_key: 'spotify_id',
          association_foreign_key: 'session_id'
  has_and_belongs_to_many :last_fm_users, class_name: 'LastFmUser', join_table: 'users_sessions',
      foreign_key: 'spotify_id', association_foreign_key: 'last_fm_id'

  validates :id, presence: true, uniqueness: true

  def to_rspotify_user
    RSpotify::User.new(JSON.parse(rspotify_hash))
  end
end