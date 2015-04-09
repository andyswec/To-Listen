class User < ActiveRecord::Base
  has_many :user_sessions, class_name: "UserSession", foreign_key: "user_id", dependent: :destroy
  has_many :sessions, through: :user_sessions

  validates :spotify_id, presence: true, uniqueness: true
end
