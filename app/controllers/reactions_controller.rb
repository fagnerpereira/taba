class ReactionsController < ApplicationController
  # TODO: Reagir a mensagens (sem reload)
  def create
    @message = Message.find(params[:reaction][:message_id])
    @reaction = @message.reactions.new(reaction_params)
    # Mocking user_id for frontend simplicity in this challenge
    @reaction.user = User.first_or_create(username: "frontend_user")

    respond_to do |format|
      if @reaction.save
        format.turbo_stream
        format.html { redirect_back_or_to(root_path) }
      else
        format.html { redirect_back_or_to(root_path, alert: "Erro ao reagir") }
      end
    end
  end

  private

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end
end
