class PlayersController < ApplicationController
	include PlayersHelper # to access helper methods, but this is not good practice

  def index
	end

  def show
    player_id = params[:id]
    team_id   = params[:team_id]
    selected_round = (params[:round] || 0).to_i

    # TEMP: Invalidate cache for all rounds while debugging
    # This works with the og @available_rounds at the bottom
    # (0..4).each do |round|
    #   Rails.cache.delete("nba/team_players/#{team_id}/2024-25/#{round}")
    # end
    # Rails.cache.delete("nba/team_totals/#{team_id}/2024-25/#{selected_round}")

    # TEMP: Invalidate cache for player rounds while debugging
    # This works with the 2nd @available_rounds 
    Rails.cache.delete("nba/player_rounds/#{team_id}/#{player_id}")

    # Get team totals for the selected round (so percentages update correctly)
    @team_totals = NbaStatsService.team_totals(team_id: team_id, season: "2024-25", poround: selected_round)
    puts "********* Debugging message from players#show @team_totals:"
    puts @team_totals

    # Player’s stats for the selected round
    players_in_round = NbaStatsService.team_players(team_id: team_id, season: "2024-25", poround: selected_round)
    puts "********* Debugging message from players#show players_in_round:"
    puts players_in_round
    @player = players_in_round.find { |p| p[:player_id].to_s == player_id.to_s }
    puts "********* Debugging message from players#show @player:"
    puts @player

    # Collect available rounds (only include if the player actually has stats in that round)

    # 2nd version
    @available_rounds = Rails.cache.fetch("nba/player_rounds/#{team_id}/#{player_id}", expires_in: 1.minute) do #was 12.hours
      [0, 1, 2, 3, 4].select do |round|
        stats = NbaStatsService.team_players(team_id: team_id, season: "2024-25", poround: round)
        stats.any? { |p| p[:player_id].to_s == player_id.to_s }
      end
    end

    # og
    # @available_rounds = [0, 1, 2, 3, 4].select do |round|
    #   stats = NbaStatsService.team_players(team_id: team_id, season: "2024-25", poround: round)
    #   stats.any? { |p| p[:player_id].to_s == player_id.to_s }
    # end

    @selected_round = selected_round

    # @stats_to_show = ["PTS", "REB", "AST", "FGM", "FGA"]
    @stats_to_show = [":pts", ":reb", ":ast", ":fgm", ":fga"]
    puts "<<<<<<debugging message before calling player_contribution_stats: @player = #{@player}"
    puts "<<<<<<debugging message before calling player_contribution_stats: @team_totals = #{@team_totals}"
    puts "<<<<<<debugging message before calling player_contribution_stats: @stats_to_show = #{@stats_to_show}"
    @player_contributions = player_contribution_stats(@player, @team_totals, stats: @stats_to_show)
    puts "@stats_to_show: #{@stats_to_show}"
    puts "@player_contributions: #{@player_contributions}"
  end  
end
