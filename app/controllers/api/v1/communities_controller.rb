module Api
  module V1
    class CommunitiesController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      def top_messages
        # TODO: Implement top messages logic
        # This is a stub implementation that will make tests fail

        @community = Community.find_by(id: params[:id])

        if @community.nil?
          render json: {
            error: "Community not found"
          }, status: :not_found
          return
        end

        # Stub: Should return top messages based on reaction count
        # Actual implementation should:
        # 1. Find messages in the community
        # 2. Count reactions for each message
        # 3. Order by reaction count descending
        # 4. Limit results (e.g., top 10)

        # Stub: Return some messages (not necessarily the top ones)
        messages = @community.messages.includes(:reactions).limit(10)

        # Calculate reaction counts (stub - not properly ordered)
        top_messages = messages.map do |message|
          {
            id: message.id,
            content: message.content,
            user_id: message.user_id,
            ai_sentiment_score: message.ai_sentiment_score,
            reaction_count: message.reactions.count,
            created_at: message.created_at
          }
        end

        render json: {
          community_id: @community.id,
          community_name: @community.name,
          message: "Top messages retrieved successfully (proper ranking pending implementation)",
          data: top_messages
        }, status: :ok
      rescue => e
        render json: {
          error: "Internal server error",
          message: e.message
        }, status: :internal_server_error
      end

      private

      def json_request?
        request.format.json?
      end
    end
  end
end
