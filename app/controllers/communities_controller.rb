class CommunitiesController < ApplicationController
  # TODO: Listagem de comunidades
  def index
    @communities = Community.all
  end

  # TODO: Timeline de mensagens
  def show
    @community = Community.find(params[:id])
    @messages = @community.messages.where(parent_message_id: nil).includes(:user, :reactions).order(created_at: :desc)
    @new_message = Message.new(community: @community)
  end
end
