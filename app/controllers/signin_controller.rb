class SigninController < ApplicationController
  def index
  	set_meta_tags :title => 'Sign In'
  	
    if anyone_signed_in?
      redirect_to current_manage_account_path
    end
  end
end
