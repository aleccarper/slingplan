class Admin::BlogController < AdminController
  layout 'admin'

  def index
    @posts = BlogPost.all
    @posts = @posts.paginate(page: params[:page] || 1)
  end

  def show
    @post = BlogPost.find(params[:id])
  end

  def new
    @post = BlogPost.new
  end

  def edit
    @post = BlogPost.find(params[:id])
  end

  def update
    @post = BlogPost.find(params[:id])
    @post.title = params[:blog_post][:title]
    @post.content = params[:blog_post][:description]
    @post.content = params[:blog_post][:content]
    @post.save
    redirect_to admin_blog_index_path
  end

  def create
    @post = BlogPost.new(params_for_post)
    @post.content.gsub!("\r\n", '')
    @post.admin = current_admin
    if @post.valid?
      @post.save
    end
    redirect_to admin_blog_index_path
  end

  def destroy
    BlogPost.find(params[:id]).destroy!
    redirect_to admin_blog_index_path
  end



  private

  def params_for_post
    params.require(:blog_post).permit(
      :title,
      :description,
      :content
    )
  end
end
