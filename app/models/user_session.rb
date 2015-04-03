class UserSession < ActiveRecord::Base
  self.table_name = :users_sessions

  validates :user_id, presence: true
  validates :session_id, presence: true
  validates_uniqueness_of :user_id, scope: :session_id
end