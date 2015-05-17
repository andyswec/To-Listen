class TrackSession < ActiveRecord::Base
  belongs_to :track, class_name: "Track", foreign_key: 'track_id'
  belongs_to :session, class_name: "Session", foreign_key: 'session_id'
  self.table_name = :tracks_sessions

  validates :session_id, presence: true
  validates :track_id, presence: true
end
