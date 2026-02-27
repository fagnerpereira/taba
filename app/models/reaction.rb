class Reaction < ApplicationRecord
  belongs_to :message
  belongs_to :user

  enum :reaction_type, {
    like: "like",
    love: "love",
    insightful: "insightful"
  }
end
