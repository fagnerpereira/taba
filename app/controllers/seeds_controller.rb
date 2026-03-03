class SeedsController < ApplicationController
  def create
    # Clear existing data
    Message.delete_all
    Reaction.delete_all
    Community.delete_all
    User.delete_all

    # Create communities
    communities = [
      { name: "Ruby on Rails Enthusiasts", description: "Discuss Rails 8, Hotwire, and Ruby code" },
      { name: "The Gaming Lounge", description: "Gaming discussions and reviews" },
      { name: "General Chat", description: "General conversations" },
      { name: "Tech News & Updates", description: "Latest technology news" }
    ].map { |c| Community.create!(c) }

    # Create users
    users = [
      "alice_wonder", "bob_builder", "charlie_dev", "diana_it",
      "eve_gamer", "frank_designer", "grace_tester", "henry_ops"
    ].map { |u| User.create!(username: u) }

    # Create messages with different IPs for testing
    user_ips = {
      "alice_wonder" => "192.168.1.10",
      "bob_builder" => "192.168.1.20",
      "charlie_dev" => "10.0.0.5",
      "diana_it" => "172.16.0.15",
      "eve_gamer" => "192.168.1.10", # Same IP as Alice - suspicious
      "frank_designer" => "10.0.0.5", # Same IP as Charlie - suspicious
      "grace_tester" => "203.0.113.45",
      "henry_ops" => "198.51.100.22"
    }

    # Create sample messages
    messages = []
    communities.each do |community|
      10.times do |i|
        user = users.sample
        message = Message.create!(
          user: user,
          community: community,
          content: "Sample message #{i + 1} for #{community.name}",
          user_ip: user_ips[user.username]
        )
        messages << message
      end
    end

    # Create reactions
    messages.each do |message|
      3.times do
        user = users.sample
        reaction_type = %w[like love heart fire party rocket laugh sad angry].sample
        
        begin
          Reaction.create!(
            user: user,
            message: message,
            reaction_type: reaction_type
          )
        rescue ActiveRecord::RecordInvalid
          # Skip duplicate reactions
        end
      end
    end

    render json: {
      message: "Database seeded successfully",
      communities: Community.count,
      users: User.count,
      messages: Message.count,
      reactions: Reaction.count
    }, status: :ok
  rescue => e
    render json: {
      error: "Seeding failed",
      message: e.message
    }, status: :internal_server_error
  end
end