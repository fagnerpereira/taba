module Api
  module V1
    class MessagesController < ApplicationController
      skip_before_action :verify_authenticity_token

      # TODO: POST /api/v1/messages (criar mensagem + sentiment)
      def create
        # TODO: Validações implementadas
        # Lógica baseada em ARCHITECTURE_IDEAS.md: Criação de Mensagem com Estado e Auto-provisionamento
        User.transaction do
          user = User.find_or_create_by!(username: params[:username])
          @message = Message.new(
            user: user,
            community_id: params[:community_id],
            content: params[:content],
            user_ip: params[:user_ip],
            parent_message_id: params[:parent_message_id]
          )

          if @message.save
            render json: {
              id: @message.id,
              content: @message.content,
              ai_sentiment_score: @message.ai_sentiment_score,
              user: { id: user.id, username: user.username },
              created_at: @message.created_at
            }, status: :created
          else
            render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue => e
        render json: { error: "Erro interno: #{e.message}" }, status: :internal_server_error
      end

      def show
        @message = Message.find(params[:id])
        render json: @message
      end
    end
  end
end
