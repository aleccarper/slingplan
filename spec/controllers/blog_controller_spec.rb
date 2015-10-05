require 'rails_helper'

RSpec.describe BlogController, type: :controller do

  describe 'GET show' do
    before :each do
      @blog_post = create(:blog_post)
    end

    context 'post is public' do
      subject { get 'show', id: @blog_post.id }

      before :each do
        @blog_post.update_attribute(:is_public, true)
      end

      it 'shows the blog post' do
        expect(subject.status).to be(200)
      end

    end

    context 'post not public' do

      before :each do
        @blog_post.update_attribute(:is_public, false)
      end

      context 'given a correct preview hash' do
        subject { get 'show', id: @blog_post.id, params: { preview_hash: @blog_post.preview_hash } }

        it 'shows the blog post' do
          expect(subject.status).to be(200)
        end
      end

      context 'without a correct preview hash' do
        subject { get 'show', id: @blog_post.id, params: { preview_hash: nil } }
        
        it 'redirects to blog index' do
          expect(subject).to redirect_to(blog_index_path)
        end
          
      end
    end
  end
end
