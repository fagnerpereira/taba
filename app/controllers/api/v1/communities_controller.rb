module Api
  module V1
    class CommunitiesController < ApplicationController
      skip_before_action :verify_authenticity_token

      # TODO: GET /api/v1/communities/:id/messages/top
      # Lógica baseada em ARCHITECTURE_IDEAS.md: Ranking de Engajamento (Prevenção de N+1)
      def top_messages
        limit = params[:limit] || 10
        @messages = Message.top_messages_for_community(params[:id], limit)
        
        render json: {
          community_id: params[:id],
          messages: @messages.as_json(methods: [:computed_engagement_score, :reactions_count, :replies_count], include: :user)
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Comunidade não encontrada" }, status: :not_found
      end
    end
  end
end
