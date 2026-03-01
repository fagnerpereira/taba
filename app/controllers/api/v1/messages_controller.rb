module Api
  module V1
    class MessagesController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      # POST /api/v1/messages
      # Creates a message with the following business rules:
      # - Find or create user if they do not exist
      # - Calculate AI sentiment score automatically
      # - Validate mandatory fields
      # def create
      #   # TODO: Implement sentiment analysis logic
      #   # This is a stub implementation that will make tests fail

      #   @message = Message.new(message_params)

      #   # Stub: Sentiment analysis should be called here
      #   # The actual implementation will analyze content and generate ai_sentiment_score

      #   if @message.save
      #     # Stub: Sentiment analysis result
      #     sentiment_score = stub_sentiment_analysis(@message.content)
      #     @message.update(ai_sentiment_score: sentiment_score)

      #     render json: {
      #       message: "Message created successfully (sentiment analysis pending implementation)",
      #       data: {
      #         id: @message.id,
      #         content: @message.content,
      #         user_id: @message.user_id,
      #         community_id: @message.community_id,
      #         ai_sentiment_score: @message.ai_sentiment_score,
      #         created_at: @message.created_at
      #       }
      #     }, status: :created
      #   else
      #     render json: {
      #       error: "Message creation failed",
      #       details: @message.errors.full_messages
      #     }, status: :unprocessable_content
      #   end
      # rescue => e
      #   render json: {
      #     error: "Internal server error",
      #     message: e.message
      #   }, status: :internal_server_error
      # end

      def create
        # binding.break
        @message = Message.new(message_params)

        respond_to do |format|
          if @message.save
            # format.html { redirect_to @message, notice: "Message was successfully created." }
            format.json { render :show, status: :created, location: @message }
          else
            # format.html { render :new, status: :unprocessable_content }
            format.json { render json: @message.errors, status: :unprocessable_content }
          end
        end
      end

      private

      def message_params
        params.expect(message: [:content, :username, :community_id, :parent_message_id, :user_ip])
      end

      def json_request?
        request.format.json?
      end

      def stub_sentiment_analysis(content)
        # Stub implementation: This will always return 0.5
        # Actual implementation should analyze content and return a score between 0 and 1
        # where 0 is very negative, 0.5 is neutral, and 1 is very positive

        # This stub will intentionally fail tests until real logic is implemented
        0.5
      end
    end
  end
end
