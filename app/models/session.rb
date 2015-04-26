class Session < ActiveRecord::Base
  has_many :user_sessions
  has_and_belongs_to_many :spotify_users, class_name: 'SpotifyUser', join_table: 'users_sessions', foreign_key:
          'session_id', association_foreign_key: 'spotify_id'
  has_and_belongs_to_many :last_fm_users, class_name: 'LastFmUser', join_table: 'users_sessions', foreign_key:
          'session_id', association_foreign_key: 'last_fm_id'

  validates :id, presence: true, uniqueness: true
end
