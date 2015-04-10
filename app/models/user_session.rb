class UserSession < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  belongs_to :session, class_name: "Session"

  self.table_name = :users_sessions

  validates :user_id, presence: true
  validates :session_id, presence: true
  validates_uniqueness_of :user_id, scope: :session_id
end