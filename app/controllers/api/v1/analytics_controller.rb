module Api
  module V1
    class AnalyticsController < ApplicationController
      # TODO: GET /api/v1/analytics/suspicious_ips
      # Lógica baseada em ARCHITECTURE_IDEAS.md: Detecção de IPs Suspeitos
      def suspicious_ips
        min_users = params[:min_users] || 3
        @ips = User.suspicious_ips(min_users: min_users.to_i)
        
        render json: {
          min_users: min_users,
          suspicious_ips: @ips
        }
      end
    end
  end
end
