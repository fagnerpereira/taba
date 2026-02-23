# db/seeds.rb

Rails.logger.debug "\n=== Starting Database Seeding ==="

Rails.logger.debug "\n--- Cleaning Database ---"
# Deleting in order of dependencies
Reaction.delete_all
Message.delete_all
Community.delete_all
User.delete_all

Rails.logger.debug "--- Creating Users ---"
users = {
  alice: User.find_or_create_by!(username: "alice_wonder"),
  bob: User.find_or_create_by!(username: "bob_builder"),
  charlie: User.find_or_create_by!(username: "charlie_dev"),
  diana: User.find_or_create_by!(username: "diana_it"),
  eve: User.find_or_create_by!(username: "eve_gamer"),
  frank: User.find_or_create_by!(username: "frank_designer"),
  grace: User.find_or_create_by!(username: "grace_tester"),
  henry: User.find_or_create_by!(username: "henry_ops")
}
Rails.logger.debug { "✓ Created #{User.count} users." }

Rails.logger.debug "\n--- Creating Communities ---"
communities = {
  rails: Community.find_or_create_by!(
    name: "Ruby on Rails Enthusiasts",
    description: "A space for discussing the latest in Rails 8, Hotwire, and elegant Ruby code."
  ),
  gaming: Community.find_or_create_by!(
    name: "The Gaming Lounge",
    description: "From retro classics to the newest AAA titles, let's play and discuss."
  ),
  general: Community.find_or_create_by!(
    name: "General Chat",
    description: "The digital watercooler. Anything and everything goes here."
  ),
  tech_news: Community.find_or_create_by!(
    name: "Tech News & Updates",
    description: "Latest technology news, product launches, and industry updates."
  )
}
Rails.logger.debug { "✓ Created #{Community.count} communities." }

Rails.logger.debug "\n--- Creating Messages & Conversations ---"

# Define IP addresses for testing suspicious_ips analytics
# These include some patterns that should be flagged as suspicious
user_ips = {
  alice: "192.168.1.10",
  bob: "192.168.1.20",
  charlie: "10.0.0.5",
  diana: "172.16.0.15",
  eve: "192.168.1.10", # Same IP as Alice - suspicious pattern
  frank: "10.0.0.5",   # Same IP as Charlie - suspicious pattern
  grace: "203.0.113.45",
  henry: "198.51.100.22"
}

# --- Rails Community Messages ---
Rails.logger.debug "Creating Rails community messages..."
rails_messages = []

# Top message #1: Popular Rails feature discussion
m1 = Message.create!(
  user: users[:charlie],
  community: communities[:rails],
  content: "What is everyone's favorite new feature in Rails 8.1? I'm loving the simplified Solid Cache setup! It has made our production deployments so much smoother.",
  ai_sentiment_score: 0.85,
  user_ip: user_ips[:charlie]
)
rails_messages << m1

# Reply thread
r1_1 = Message.create!(
  user: users[:alice],
  community: communities[:rails],
  parent_message: m1,
  content: "Definitely Solid Queue for me. It makes the default installation so much leaner for VPS deployments. No more Redis dependency for basic queueing!",
  ai_sentiment_score: 0.92,
  user_ip: user_ips[:alice]
)

r1_2 = Message.create!(
  user: users[:bob],
  community: communities[:rails],
  parent_message: m1,
  content: "I'm just happy about the built-in authentication generator updates. The new setup saved me at least 2 hours of boilerplate code this morning!",
  ai_sentiment_score: 0.95,
  user_ip: user_ips[:bob]
)

Message.create!(
  user: users[:diana],
  community: communities[:rails],
  parent_message: m1,
  content: "The improved error messages are a game-changer. So much more helpful for debugging, especially for newcomers to Rails.",
  ai_sentiment_score: 0.88,
  user_ip: user_ips[:diana]
)

# Top message #2: Another popular thread
m2 = Message.create!(
  user: users[:alice],
  community: communities[:rails],
  content: "Hotwire + Turbo 8 is absolutely incredible! The morphing features have eliminated so much of the JavaScript complexity from our apps. Who else is using it in production?",
  ai_sentiment_score: 0.90,
  user_ip: user_ips[:alice]
)
rails_messages << m2

# --- Gaming Community Messages ---
Rails.logger.debug "Creating Gaming community messages..."
gaming_messages = []

m3 = Message.create!(
  user: users[:bob],
  community: communities[:gaming],
  content: "Just finished the new Zelda DLC. The final boss was incredibly challenging but the satisfaction after beating it was amazing! Best 40 hours of gaming this year.",
  ai_sentiment_score: 0.75,
  user_ip: user_ips[:bob]
)
gaming_messages << m3

# Reply thread
Message.create!(
  user: users[:eve],
  community: communities[:gaming],
  parent_message: m3,
  content: "No spoilers please! I'm only halfway through the fire temple. The puzzle design in this one is absolutely brilliant though.",
  ai_sentiment_score: 0.65,
  user_ip: user_ips[:eve] # Same IP as Alice - suspicious!
)

# Another gaming thread
m4 = Message.create!(
  user: users[:eve],
  community: communities[:gaming],
  content: "Anyone excited for the new indie game releases next month? I've been following three titles that look absolutely stunning. The indie scene is carrying gaming innovation!",
  ai_sentiment_score: 0.80,
  user_ip: user_ips[:eve]
)
gaming_messages << m4

# --- General Chat Messages ---
Rails.logger.debug "Creating General chat messages..."
general_messages = []

m5 = Message.create!(
  user: users[:diana],
  community: communities[:general],
  content: "Good morning everyone! Hope you all have a productive Friday. The weather is finally getting better here. ☕️🌞",
  ai_sentiment_score: 0.99,
  user_ip: user_ips[:diana]
)
general_messages << m5

m6 = Message.create!(
  user: users[:frank],
  community: communities[:general],
  content: "Just finished an amazing book on design systems. Really changed how I approach component architecture. Has anyone else read it?",
  ai_sentiment_score: 0.87,
  user_ip: user_ips[:frank] # Same IP as Charlie - suspicious!
)
general_messages << m6

# --- Tech News Community ---
Rails.logger.debug "Creating Tech News community messages..."
tech_messages = []

m7 = Message.create!(
  user: users[:grace],
  community: communities[:tech_news],
  content: "The new AI regulations announced today are going to have massive implications for startups. Compliance costs might stifle innovation in the space.",
  ai_sentiment_score: 0.45,
  user_ip: user_ips[:grace]
)
tech_messages << m7

m8 = Message.create!(
  user: users[:henry],
  community: communities[:tech_news],
  content: "Quantum computing breakthrough announced! Researchers achieved 99.9% fidelity in error correction. This could be the tipping point.",
  ai_sentiment_score: 0.82,
  user_ip: user_ips[:henry]
)
tech_messages << m8

m9 = Message.create!(
  user: users[:charlie],
  community: communities[:tech_news],
  content: "The open-source community is pushing back against corporate contributions that don't align with community values. Interesting governance discussions happening.",
  ai_sentiment_score: 0.60,
  user_ip: user_ips[:charlie]
)
tech_messages << m9
Rails.logger.debug { "✓ Created #{Message.count} messages." }

Rails.logger.debug "\n--- Adding Reactions (for testing top messages) ---"

# Add many reactions to m1 (Rails community) to make it a "top message"
Rails.logger.debug "Adding reactions to popular Rails discussion..."
reactions_data = [
  {message: m1, user: users[:alice], types: ["rocket", "heart", "like"]},
  {message: m1, user: users[:bob], types: ["like", "fire"]},
  {message: m1, user: users[:charlie], types: ["heart"]},
  {message: m1, user: users[:diana], types: ["rocket", "like", "fire"]},
  {message: m1, user: users[:eve], types: ["like"]},
  {message: m1, user: users[:frank], types: ["heart", "rocket"]},
  {message: m1, user: users[:grace], types: ["like", "fire"]},
  {message: m1, user: users[:henry], types: ["rocket"]}
]

reactions_data.each do |data|
  data[:types].each do |reaction_type|
    Reaction.create!(
      user: data[:user],
      message: data[:message],
      reaction_type: reaction_type
    )
  end
end

# Add reactions to m2 (another popular Rails message)
Rails.logger.debug "Adding reactions to another popular message..."
reactions_data_m2 = [
  {message: m2, user: users[:bob], types: ["party", "like"]},
  {message: m2, user: users[:charlie], types: ["party", "rocket", "like"]},
  {message: m2, user: users[:diana], types: ["like"]},
  {message: m2, user: users[:frank], types: ["rocket"]},
  {message: m2, user: users[:grace], types: ["like", "party"]}
]

reactions_data_m2.each do |data|
  data[:types].each do |reaction_type|
    Reaction.create!(
      user: data[:user],
      message: data[:message],
      reaction_type: reaction_type
    )
  end
end

# Add some reactions to other messages for variety
Rails.logger.debug "Adding reactions to other messages..."
Reaction.create!(user: users[:charlie], message: m3, reaction_type: "heart")
Reaction.create!(user: users[:diana], message: m3, reaction_type: "like")

# Add reactions to replies as well
Reaction.create!(user: users[:charlie], message: r1_1, reaction_type: "rocket")
Reaction.create!(user: users[:henry], message: r1_2, reaction_type: "like")

Rails.logger.debug { "✓ Created #{Reaction.count} reactions." }

Rails.logger.debug "\n--- Seeding Summary ---"
Rails.logger.debug { "✓ Users: #{User.count} (including potential duplicate IPs for testing)" }
Rails.logger.debug { "✓ Communities: #{Community.count}" }
Rails.logger.debug { "✓ Messages: #{Message.count} (including threads and replies)" }
Rails.logger.debug { "✓ Reactions: #{Reaction.count} (concentrated on top messages)" }

Rails.logger.debug "\n=== Seeding Complete Successfully! ==="
Rails.logger.debug "Data ready for testing API endpoints and analytics."
Rails.logger.debug "\nNote: Some users share IPs (alice/eve and charlie/frank) for testing suspicious_ips analytics."
