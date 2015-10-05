require 'rails_helper'

RSpec.describe BlogPost, type: :model do

  describe '#preview_hash' do

    it 'is a sha265 hexdigest based on the title' do
      title = 'Test Title'
      blog_post = create(:blog_post, title: title)
      expected = Digest::SHA256.hexdigest title

      blog_post.save

      expect(blog_post.preview_hash).to eq(expected)
    end
  end

  describe '#description' do
    it 'is required' do
      blog_post = build(:blog_post)

      blog_post.description = ''
      expect(blog_post.save).to eq(false)

      blog_post.description = 'Something'
      expect(blog_post.save).to eq(true)
    end
  end

  describe '#is_public' do
    it 'defaults to false' do
      blog_post = create(:blog_post)
      expect(blog_post.is_public).to eq(false)
    end
  end

  describe '#preview_authenticated?' do
    it 'is true if valid' do
      blog_post = create(:blog_post)
      hash = Digest::SHA256.hexdigest blog_post.title

      expect(blog_post.preview_authenticated?(hash)).to eq(true)
    end

    it 'is false if not valid' do
      blog_post = create(:blog_post)
      hash = 'invalid'

      expect(blog_post.preview_authenticated?(hash)).to eq(false)
    end
  end

end
