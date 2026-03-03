class Reaction < ApplicationRecord
  # TODO: Validações implementadas
  validates :reaction_type, presence: true
  # Constraint UNIQUE [message_id, user_id, reaction_type] handled by DB index
  
  belongs_to :user
  belongs_to :message

  # TODO: POST /api/v1/reactions (com proteção de concorrência)
  # Uniqueness validation at application level as first line of defense
  validates :reaction_type, uniqueness: { scope: [:message_id, :user_id], message: "Usuário já reagiu com este tipo" }
end
