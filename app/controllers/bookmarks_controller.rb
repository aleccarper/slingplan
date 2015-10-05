class BookmarksController < ApplicationController

  before_action :before

  def add
    unless @ids.include? @id
      @ids << @id
    end

    @ids = @ids.delete_if { |n| [nil, 0, '0'].include? n }

    set_cookie_bookmarks(@ids)

    render json: { bookmarks: @ids }
  end

  def add_to_bookmark_list
    @bookmark_list_id = params[:bookmark_list_id].to_i
    bookmark_list = BookmarkList.find(@bookmark_list_id)

    unless [nil, 0, '0'].include? @id
      loc = Location.find_by(id: @id)
      unless loc.nil?
        bookmark_list.bookmarks << Bookmark.new({
          location: loc
        })
      end
    end

    return render json: {
      bookmarks: bookmark_list.bookmarks.map(&:location).map(&:id)
    }
  end

  def remove
    if @ids.include? @id
      @ids.delete @id
    end
    set_cookie_bookmarks(@ids)

    render json: { bookmarks: @ids }
  end

  def remove_from_bookmark_list
    @bookmark_list_id = params[:bookmark_list_id].to_i
    bookmark_list = BookmarkList.find(@bookmark_list_id)
    bookmark = bookmark_list.bookmarks.find_by(location_id: @id)
    bookmark_list.bookmarks.delete(bookmark)

    return render json: {
      bookmarks: bookmark_list.bookmarks.map(&:location).map(&:id)
    }
  end

  def email
    email = params[:email]
    BookmarksMailer.delay.export(email, @ids)
    head :ok, content_type: 'text/html'
  end

  def print_friendly
    unless params[:bookmark_list_id].nil?
      bookmark_list = BookmarkList.find(params[:bookmark_list_id])
    end

    render({
      template: 'bookmarks/print_friendly',
      layout: false,
      locals: {
        bookmark_list: bookmark_list || nil
      }
    })
  end

  def to_file
    if params[:bookmark_list_id]
      @bookmark_list_id = params[:bookmark_list_id].to_i
      @bookmark_list = BookmarkList.find(@bookmark_list_id)
      @locations = @bookmark_list.bookmarks.map(&:location)
      file_name = "#{@bookmark_list.name}.#{params[:format]}"
    else
      @locations = Location.where('id IN (?)', @ids)
      file_name = "event.#{params[:format]}"
    end

    respond_to do |format|
      format.csv { send_data(@locations.to_comma, filename: file_name) }
      format.xls do
        response.headers['Content-Disposition'] = "attachment; filename=#{file_name}"
        render "to_file.xls.erb"
      end
    end
  end

  def create_bookmark_list
    bookmark_list = BookmarkList.new({ planner: current_planner }.merge(bookmark_list_params))

    bookmark_list.bookmarks = @ids.map do |id|
      Bookmark.new(location: Location.find(id))
    end

    if bookmark_list.valid?
      bookmark_list.save

      set_cookie_bookmarks([]);

      render json: {
        bookmark_list: bookmark_list
      }
    end
  end

  def delete_bookmarks_list
    bookmark_list = BookmarkList.find(params[:bookmark_list_id])

    current_planner.bookmark_lists.delete(bookmark_list)

    head :ok, content_type: 'text/html'
  end



  private

  def before
    @id = params[:id].to_i
    @ids = get_cookie_bookmarks
  end

  def bookmark_list_params
    params.require(:bookmark_list).permit(:name)
  end

end
