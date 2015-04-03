class Session < ActiveRecord::Base
  validates :id, uniqueness: true
end
