module Api
  module V1
    class AnalyticsController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      def suspicious_ips
        min_users = params[:min_users].to_i.positive? ? params[:min_users].to_i : 2

        ip_user_counts = Message.distinct
          .group(:user_ip)
          .select("user_ip, COUNT(DISTINCT user_id) as user_count")
          .having("COUNT(DISTINCT user_id) >= ?", min_users)
          .order("user_count DESC")

        suspicious_ips = ip_user_counts.map do |ip_data|
          users = Message.where(user_ip: ip_data.user_ip)
            .includes(:user)
            .distinct
            .map { |m| m.user.username }
          {
            ip: ip_data.user_ip,
            user_count: ip_data.user_count.to_i,
            users: users.uniq
          }
        end

        render json: {
          message: "Suspicious IP analysis completed",
          suspicious_ips_count: suspicious_ips.length,
          data: suspicious_ips
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
