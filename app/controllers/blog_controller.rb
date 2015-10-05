class BlogController < ApplicationController

  def index
    set_meta_tags :title => 'Blog'

    @posts = BlogPost.where(is_public: true)
    @posts = @posts.paginate(:page => params[:page] || 1).order(id: :desc)
  end

  def show
    @post = BlogPost.find(params[:id])

    title = @post.title || 'Blog'

    set_meta_tags :title => title,
                  :twitter => {
                    :title => 'SlingPlan | ' + title,
                  },
                  :og => {
                    :url => 'slingplan.com',
                    :title => 'SlingPlan | ' + title,
                    :type => 'article'
                  }


    if @post.description
      set_meta_tags :description => @post.description,
                    :twitter => {
                      :description => @post.description
                    },
                    :og => {
                      :description => @post.description,
                    }
    end

    unless @post.is_public || @post.preview_authenticated?(params[:preview_hash])
      redirect_to blog_index_path
    end
  end

end
