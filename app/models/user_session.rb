class UserSession < ActiveRecord::Base
  belongs_to :spotify_user, class_name: "SpotifyUser", foreign_key: 'spotify_id'
  belongs_to :session, class_name: "Session", foreign_key: 'session_id'
  self.table_name = :users_sessions

  validates :session_id, presence: true
  validates :spotify_id, presence: true
  validates_uniqueness_of :spotify_id, scope: [:session_id]
end