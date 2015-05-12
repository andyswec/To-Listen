class UserSession < ActiveRecord::Base
  belongs_to :spotify_user, class_name: "SpotifyUser", foreign_key: 'spotify_id'
  belongs_to :last_fm_user, class_name: "LastFmUser", foreign_key: 'last_fm_id'
  belongs_to :session, class_name: "Session", foreign_key: 'session_id'
  self.table_name = :users_sessions

  validates :session_id, presence: true
  validates_uniqueness_of :spotify_id, scope: [:session_id], allow_nil: true, allow_blank: true
  validates_uniqueness_of :last_fm_id, scope: [:session_id], allow_nil: true, allow_blank: true
  validate :has_a_user

  def has_a_user
    errors.add(:base, 'must add at least one of spotify_id, last_fm_id') if self.spotify_user.blank? && self.last_fm_user.blank?
  end
end