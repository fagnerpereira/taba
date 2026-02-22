module Api
  module V1
    class AnalyticsController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      def suspicious_ips
        # TODO: Implement suspicious IPs detection logic
        # This is a stub implementation that will make tests fail

        # Stub: Should identify IP addresses with suspicious patterns:
        # 1. Same IP used by multiple users
        # 2. Unusual message creation rates
        # 3. Suspicious sentiment patterns
        # 4. Geographic anomalies

        # For now, return an empty array to make tests fail
        # Actual implementation would analyze the messages table

        suspicious_ips = []

        # Stub implementation that will not detect the suspicious patterns
        # in our seeds data (alice/eve share IP, charlie/frank share IP)

        binding.irb

        render json: {
          message: "Suspicious IP analysis completed (detection logic pending implementation)",
          suspicious_ips_count: suspicious_ips.length,
          data: suspicious_ips
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
