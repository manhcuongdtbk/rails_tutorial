class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    user ? email_info : email_danger
  end

  def edit; end

  def update
    return empty_password if params[:user][:password].empty?
    return update_success if user.update_attributes user_params
    render :edit
  end

  private

  attr_reader :user

  def email_info
    user.create_reset_digest
    user.send_password_reset_email
    flash[:info] = t "password_resets_info"
    redirect_to root_url
  end

  def email_danger
    flash.now[:danger] = t "password_resets_danger"
    render :new
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def find_user
    @user = User.find_by email: params[:email]
    return if user
    flash.now[:danger] = t "password_resets_danger"
  end

  def valid_user
    return if user && user.activated? && user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless user.password_reset_expired?
    flash[:danger] = t "password_resets_expired"
    redirect_to new_password_reset_url
  end

  def empty_password
    user.errors.add :password, t("empty_password")
    render :edit
  end

  def update_success
    log_in user
    user.update_attributes reset_digest: nil
    flash[:success] = t "password_resets_success"
    redirect_to user
  end
end
