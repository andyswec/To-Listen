class User < ActiveRecord::Base
  has_many :user_sessions, class_name: "UserSession", foreign_key: "user_id", dependent: :destroy
  has_many :sessions, through: :user_sessions
  validates_uniqueness_of :spotify_id, :last_fm_username

  def has_an_id
    unless [spotify_id, last_fm_username].any? { |val| val.present? }
      errors.add :base, 'You need at least one id!'
    end
  end
end
