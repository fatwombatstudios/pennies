class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def must_be_signed_in
    redirect_to sign_in_path unless current_user

    @account = current_user.account
  end
end
