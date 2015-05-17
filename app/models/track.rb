require 'rspotify'

class Track < ActiveRecord::Base
  has_many :track_sessions
  has_and_belongs_to_many :sessions, class_name: "Session", join_table: 'tracks_sessions', foreign_key: 'track_id',
                          association_foreign_key: 'session_id'

  validates :id, presence: true, uniqueness: true

  serialize :rspotify_hash, RSpotify::Track
end
