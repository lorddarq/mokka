class ApplicationController < ActionController::Base
  protect_from_forgery

  # before_filter :authenticate
  # before_filter :logout_if_no_cookie_available, :if => :logged_in?

  helper_method :controller_and_action

  private

  # def logout_if_no_cookie_available
  #   logout if !LamAuth.access_token_from_cookie(cookies[LamAuth.cookie_id])
  # end

  def controller_and_action
    "#{controller_path}##{action_name}"
  end
end
