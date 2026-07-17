class PlayersController < ApplicationController
	include PlayersHelper # to access helper methods, but this is not good practice

  def index
  end

  def show
    player_id = params[:id]
    team_id   = params[:team_id]
    selected_round = (params[:round] || 0).to_i

    # Get team totals for the selected round (so percentages update correctly)
    @team_totals = NbaStatsService.team_totals(
      team_id: team_id,
      season: "2025-26",
      poround: selected_round
    )

    # Player’s stats for the selected round
    players_in_round = NbaStatsService.team_players(
      team_id: team_id,
      season: "2025-26",
      poround: selected_round
    )
    @player = players_in_round.find { |p| p[:player_id].to_s == player_id.to_s }

    # Collect available rounds (only include if the player actually has stats in that round)
    @available_rounds = Rails.cache.fetch("nba/player_rounds/#{team_id}/#{player_id}", expires_in: 12.hours) do
      [0, 1, 2, 3, 4].select do |round|
        stats = NbaStatsService.team_players(
          team_id: team_id,
          season: "2025-26",
          poround: round
        )
        stats.any? { |p| p[:player_id].to_s == player_id.to_s }
      end
    end

    @selected_round = selected_round

    @selected_round_label =
      case @selected_round
      when 1
        "First Round"
      when 2
        "Semifinals"
      when 3
        "Conference Finals"
      when 4
        "Finals"
      else
        "All Rounds"
      end

    @stats_to_show = [
      :min,
      :pts,
      :fgm,
      :fga,
      :fg3m,
      :fg3a,
      :ftm,
      :fta,
      :reb,
      :oreb,
      :dreb,
      :ast,
      :stl,
      :blk,
      :pfd,
      :tov,
      :blka,
      :pf,
    ]
    
    # Compute the player’s contributions for the selected stats
    @player_contributions = player_contribution_stats(@player, @team_totals, stats: @stats_to_show)

    # Get rankings for all players in the selected round
    all_player_rankings =
      player_rankings(
        players_in_round,
        stats: @stats_to_show
      )

    # Get the rankings for the selected player for each stat
    @player_rankings =
      @stats_to_show.index_with do |stat|
        all_player_rankings[stat][@player[:player_id]]
      end

    # Get playoff opponent for the selected round
    @playoff_opponent =
      NbaStatsService.playoff_opponent(
        team_id: team_id,
        season: "2025-26",
        poround: selected_round
      )
  end  
end
