class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase

    if user && user.authenticate(params[:session][:password])
      user.activated? ? login_success(user) : unactivated_user
    else
      login_false
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def login_success user
    log_in user
    params_session[:remember_me] == "1" ? remember(user) : forget(user)
    redirect_back_or user
  end

  def unactivated_user
    flash[:warning] = t "warning"
    redirect_to root_url
  end

  def login_false
    flash.now[:danger] = t "danger"
    render :new
  end

  def params_session
    params[:session]
  end
end
