class PlayersController < ApplicationController

	def index
	end

  def show
    player_id = params[:id]
    team_id = params[:team_id] # optional if you nest under teams

    # Player totals from the team stats endpoint
    team_players = NbaStatsService.team_players(team_id: team_id, season: "2024-25")
    @player = team_players.find { |p| p[:player_id].to_s == player_id.to_s }

    # Get team totals to compare player vs. team
    @team_totals = NbaStatsService.team_totals(team_id: team_id, season: "2024-25")
  end
end
