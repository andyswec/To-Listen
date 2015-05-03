class LastFmUser < ActiveRecord::Base
  has_many :user_sessions
  has_and_belongs_to_many :sessions, class_name: "Session", join_table: 'users_sessions', foreign_key: 'last_fm_id',
          association_foreign_key: 'session_id'
  has_and_belongs_to_many :spotify_users, class_name: 'SpotifyUser', join_table: 'users_sessions', foreign_key:
          'last_fm_id', association_foreign_key: 'spotify_id'


  validates :id, presence: true, uniqueness: true
end
