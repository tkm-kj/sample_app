FactoryGirl.define do
  factory :user do
    name 'hoge hoge'
    email 'hoge@example.com'
    password 'foobar'
    password_confirmation 'foobar'
  end
end