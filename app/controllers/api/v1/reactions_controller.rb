module Api
  module V1
    class ReactionsController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      def create
        @reaction = Reaction.new(reaction_params)

        if @reaction.save
          render json: {
            message: "Reaction created successfully",
            data: {
              id: @reaction.id,
              reaction_type: @reaction.reaction_type,
              message_id: @reaction.message_id,
              user_id: @reaction.user_id,
              created_at: @reaction.created_at
            }
          }, status: :created
        else
          render json: {
            error: "Reaction creation failed",
            details: @reaction.errors.full_messages
          }, status: :unprocessable_content
        end
      rescue ActionController::ParameterMissing
        render json: {error: "Missing parameter"}, status: :unprocessable_content
      rescue => e
        render json: {error: "Internal server error", message: e.message}, status: :internal_server_error
      end

      private

      def reaction_params
        params.require(:reaction).permit(:reaction_type, :user_id, :message_id)
      end

      def json_request?
        request.format.json?
      end
    end
  end
end
