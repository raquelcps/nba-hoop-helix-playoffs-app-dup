class PlayersController < ApplicationController

	def index
	end

  def show
    player_id = params[:id]
    team_id   = params[:team_id]
    selected_round = (params[:round] || 0).to_i

    # Get team totals for the selected round (so percentages update correctly)
    @team_totals = NbaStatsService.team_totals(team_id: team_id, season: "2024-25", poround: selected_round)

    # Player’s stats for the selected round
    players_in_round = NbaStatsService.team_players(team_id: team_id, season: "2024-25", poround: selected_round)
    @player = players_in_round.find { |p| p[:player_id].to_s == player_id.to_s }
    puts "********* Debugging message from players#show @player:"
    puts @player.inspect

    # Collect available rounds (only include if the player actually has stats in that round)
    @available_rounds = [0, 1, 2, 3, 4].select do |round|
      stats = NbaStatsService.team_players(team_id: team_id, season: "2024-25", poround: round)
      stats.any? { |p| p[:player_id].to_s == player_id.to_s }
    end

    @selected_round = selected_round
  end  
end
