class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :reaction_type, presence: true
  validates :user, presence: true
  validates :message, presence: true
end
