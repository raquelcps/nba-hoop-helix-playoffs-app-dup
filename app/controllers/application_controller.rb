class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_playoff_teams

  private
  
  def set_playoff_teams
    @teams ||= NbaStatsService.playoff_teams(season: "2024-25")
  end
end
