class User < ApplicationRecord
  # TODO: Validações implementadas
  validates :username, presence: true, uniqueness: true

  has_many :messages, dependent: :destroy
  has_many :reactions, dependent: :destroy

  # TODO: GET /api/v1/analytics/suspicious_ips
  # Returns IPs used by multiple users
  def self.suspicious_ips(min_users: 3)
    Message.joins(:user)
      .group(:user_ip)
      .having("COUNT(DISTINCT users.id) >= ?", min_users)
      .select("user_ip as ip, COUNT(DISTINCT users.id) as user_count, ARRAY_AGG(DISTINCT users.username) as usernames")
  end
end
