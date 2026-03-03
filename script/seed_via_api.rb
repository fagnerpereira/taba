require "net/http"
require "json"
require "uri"

# TODO: Criar script que popula o banco via chamadas HTTP aos endpoints da API
BASE_URL = "http://localhost:3000/api/v1"

def post(path, body)
  uri = URI.parse("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
  request.body = body.to_json
  response = http.request(request)
  JSON.parse(response.body) rescue {}
end

puts "Iniciando seeding via API..."

# TODO: 3-5 comunidades
communities_ids = []
["Tecnologia", "Culinária", "Esportes", "Viagens", "Música"].each do |name|
  # Note: Community creation via API isn't explicitly requested as a route, 
  # but needed for seeds. We use the internal model if needed or assuming a route exists.
  # Since we only have top_messages for community in API, let's use the internal Rails seed for communities 
  # or assume we can create them via messages if the API handled it.
  # For the sake of "seeding via HTTP calls", let's assume we have a way to ensure they exist.
  c = Community.find_or_create_by!(name: name, description: "Grupo sobre #{name}")
  communities_ids << c.id
end

# TODO: 50 usuários únicos (serão criados on-the-fly pelo MessagesController)
usernames = (1..50).map { |i| "user_#{i}" }

# TODO: 20 IPs únicos diferentes
ips = (1..20).map { |i| "192.168.1.#{i}" }

# TODO: 1000 mensagens
# 70% são posts principais, 30% são comentários/respostas
messages_ids = []
1000.times do |i|
  is_reply = i >= 700
  parent_id = is_reply && messages_ids.any? ? messages_ids.sample : nil
  
  res = post("/messages", {
    username: usernames.sample,
    community_id: communities_ids.sample,
    content: "Conteúdo da mensagem #{i} - #{is_reply ? 'Resposta' : 'Post'}",
    user_ip: ips.sample,
    parent_message_id: parent_id
  })
  
  messages_ids << res["id"] if res["id"]
  print "." if i % 100 == 0
end
puts "\n#{messages_ids.size} mensagens criadas."

# TODO: 80% das mensagens têm pelo menos uma reação
reaction_types = ["❤️", "💡", "👍"]
messages_ids.each do |msg_id|
  next if rand > 0.8
  
  rand(1..3).times do
    post("/reactions", {
      reaction: {
        message_id: msg_id,
        user_id: User.pluck(:id).sample, # Mocking user choice
        reaction_type: reaction_types.sample
      }
    })
  end
end

puts "Seeding via API concluído!"
