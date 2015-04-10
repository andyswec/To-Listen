class User < ActiveRecord::Base
  has_many :user_sessions, class_name: "UserSession", foreign_key: "user_id", dependent: :destroy
  has_many :sessions, through: :user_sessions

  # validates :spotify_id, uniqueness: true
  # validates :last_fm_username, uniqueness: true

  # validates :spotify_id, :presence => {:if => (last_fm_username.blank?)}


  def has_an_id
    unless [spotify_id, last_fm_username].any? { |val| val.present? }
      errors.add :base, 'You need at least one id!'
    end
  end

  # validate :at_least_one_id
  # def at_least_one_id
  #   if [self.spotify_id, self.last_fm_username].reject(&:blank?).size == 0
  #     errors[:base] << ("Please choose at least one id.")
  #   end
  # end
end
