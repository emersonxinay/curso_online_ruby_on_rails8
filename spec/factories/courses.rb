FactoryBot.define do
  factory :course do
    title { "MyString" }
    description { "MyText" }
    price { "9.99" }
    status { 1 }
    user { nil }
  end
end
