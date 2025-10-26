class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Task 3.7: Authentication helpers
  helper_method :current_user, :logged_in?

  # Don't require authentication by default
  # Controllers that need authentication should add: before_action :require_authentication

  private

  # Returns the currently logged in user or nil
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Returns true if a user is logged in
  def logged_in?
    current_user.present?
  end

  # Before action to require authentication
  # Store return_to path before redirecting
  def require_authentication
    unless logged_in?
      session[:return_to] = request.fullpath
      redirect_to signin_path, alert: "Please sign in to continue"
    end
  end
end
