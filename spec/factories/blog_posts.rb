FactoryGirl.define do
  factory :blog_post do
    sequence(:title) { |n| "blog post #{n}" }
    description 'Blog post description'
    content 'Blog post content'
    is_public false
  end
end
