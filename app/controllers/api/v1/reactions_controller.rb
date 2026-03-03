module Api
  module V1
    class ReactionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      # TODO: POST /api/v1/reactions (com proteção de concorrência)
      # Lógica baseada em ARCHITECTURE_IDEAS.md: Reação com Proteção de Concorrência
      def create
        message = Message.find(params[:reaction][:message_id])

        # Pessimistic Locking as per ARCHITECTURE_IDEAS.md
        message.with_lock do
          @reaction = Reaction.new(reaction_params)
          if @reaction.save
            render json: {
              message_id: message.id,
              reactions_count: message.reactions.group(:reaction_type).count
            }, status: :created
          else
            # TODO: Tratamento de erros apropriado
            status = @reaction.errors[:reaction_type].include?("Usuário já reagiu com este tipo") ? :conflict : :unprocessable_entity
            render json: {errors: @reaction.errors.full_messages}, status: status
          end
        end
      rescue ActiveRecord::RecordNotUnique
        # Referring to TODO: POST /api/v1/reactions (com proteção de concorrência)
        render json: {error: "Usuário já reagiu com este tipo"}, status: :conflict
      rescue ActiveRecord::RecordNotFound
        render json: {error: "Mensagem não encontrada"}, status: :not_found
      rescue => e
        render json: {error: "Erro interno: #{e.message}"}, status: :internal_server_error
      end

      private

      def reaction_params
        params.require(:reaction).permit(:message_id, :user_id, :reaction_type)
      end
    end
  end
end
