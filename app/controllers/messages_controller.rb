class MessagesController < ApplicationController
  # TODO: Criar mensagem (sem reload)
  def create
    @community = Community.find(params[:community_id])
    @message = @community.messages.new(message_params)
    @message.user = User.find_or_create_by(username: params[:username])

    respond_to do |format|
      if @message.save
        format.turbo_stream
        format.html { redirect_to community_path(@community) }
      else
        format.html { render "communities/show", status: :unprocessable_entity }
      end
    end
  end

  # TODO: Ver thread de comentários
  def show
    @message = Message.find(params[:id])
    @replies = @message.replies.includes(:user, :reactions).order(created_at: :asc)
    @new_reply = Message.new(community: @message.community, parent_message: @message)
  end

  private

  def message_params
    params.require(:message).permit(:content, :user_ip, :parent_message_id)
  end
end
