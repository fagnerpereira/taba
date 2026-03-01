FactoryBot.define do
  factory :message do
    user
    community
    content { "Hello, world!" }
    user_ip { "127.0.0.1" }

    trait :reply do
      association :parent_message, factory: :message
    end
  end
end
