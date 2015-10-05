# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    read false
    title "MyString"
    message "MyString"
    link "MyString"
  end
end
