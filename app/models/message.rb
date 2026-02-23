class Message < ApplicationRecord
  belongs_to :user
  belongs_to :community
  belongs_to :parent_message, class_name: "Message", optional: true
  has_many :replies, class_name: "Message", foreign_key: "parent_message_id", dependent: :destroy
  has_many :reactions, dependent: :destroy

  attribute :username, :string

  before_validation :set_user

  def set_user
    self.user = User.find_or_create_by(username: username)
  end
end
