module Api
  module V1
    class ReactionsController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      def create
        # TODO: Implement concurrency protection logic
        # This is a stub implementation that will make tests fail

        # Stub: Concurrency protection should be implemented here
        # This should use optimistic locking, database constraints, or row-level locking
        # to prevent race conditions when multiple users create reactions simultaneously

        @reaction = Reaction.new(reaction_params)

        # Stub: Simulating concurrency check - this will always pass
        # Actual implementation should check for duplicate reactions, handle race conditions,
        # and use database transactions or locking mechanisms

        if @reaction.save
          render json: {
            message: "Reaction created successfully (concurrency protection pending implementation)",
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
      rescue ActiveRecord::RecordNotUnique => e
        # This is the expected error for concurrency violations in the real implementation
        render json: {
          error: "Duplicate reaction - concurrency protection would prevent this",
          message: "A reaction from this user for this message already exists"
        }, status: :conflict
      rescue => e
        render json: {
          error: "Internal server error",
          message: e.message
        }, status: :internal_server_error
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
