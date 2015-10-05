class BetaController < ApplicationController

  def index
    @beta_tester = BetaTester.find_by_email(get_cookie('beta_tester_email'))
  end

  def login
    email = params[:beta_tester][:email].strip
    password = params[:beta_tester][:password]

    @beta_tester = BetaTester.find_by_email(email)

    if @beta_tester.nil?
      flash[:email_error] = 'No beta tester found with that email.'
    elsif !@beta_tester.authenticate(password)
      flash[:password_error] = 'Password invalid.'
    else
      set_cookie('beta_tester_email', email)
    end

    redirect_to root_path
  end

end
