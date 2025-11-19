class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_account
    @current_account ||= current_user.account if current_user
  end

  def must_be_signed_in
    redirect_to sign_in_path if current_account.nil?
  end
end
