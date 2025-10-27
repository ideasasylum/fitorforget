class HomeController < ApplicationController
  def index
    # Redirect authenticated users to dashboard
    redirect_to dashboard_path if logged_in?
  end
end
