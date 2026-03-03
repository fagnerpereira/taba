module Api
  module V1
    class CommunitiesController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      def top_messages
        @community = Community.find_by(id: params[:id])

        if @community.nil?
          render json: {error: "Community not found"}, status: :not_found
          return
        end

        limit = params[:limit].to_i.positive? ? params[:limit].to_i : 10

        top_messages = @community.messages
          .left_joins(:reactions)
          .group("messages.id")
          .order("COUNT(reactions.id) DESC, messages.created_at DESC")
          .limit(limit)
          .select("messages.id, messages.content, messages.user_id, messages.ai_sentiment_score, messages.created_at, COUNT(reactions.id) as reaction_count")

        render json: {
          community_id: @community.id,
          community_name: @community.name,
          message: "Top messages retrieved successfully",
          data: top_messages.map do |message|
            {
              id: message.id,
              content: message.content,
              user_id: message.user_id,
              ai_sentiment_score: message.ai_sentiment_score,
              reaction_count: message.reaction_count.to_i,
              created_at: message.created_at
            }
          end
        }, status: :ok
      rescue => e
        render json: {error: "Internal server error", message: e.message}, status: :internal_server_error
      end

      private

      def json_request?
        request.format.json?
      end
    end
  end
end
