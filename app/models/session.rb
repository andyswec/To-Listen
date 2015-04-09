class Session < ActiveRecord::Base
  has_many :user_sessions, class_name: "UserSession", foreign_key: "session_id", dependent: :destroy
  has_many :users, through: :user_sessions

  validates :id, uniqueness: true
end
