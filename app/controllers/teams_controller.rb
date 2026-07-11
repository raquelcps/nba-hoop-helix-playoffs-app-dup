class TeamsController < ApplicationController
	def index
	end

	def show
		team_id = params[:id]
		selected_round = (params[:round] || 0).to_i

		@available_rounds = [0, 1, 2, 3, 4].select do |round|
			NbaStatsService.team_players(
				team_id: team_id,
				season: "2025-26",
				poround: round
			).any?
		end
		@selected_round = selected_round

    # Team totals for grid
    @team_totals = NbaStatsService.team_totals(
			team_id: team_id,
			season: "2025-26",
			poround: selected_round
		)

    # Player totals for top 5 lists
    @players = NbaStatsService.team_players(
			team_id: team_id,
			season: "2025-26",
			poround: selected_round
		)
		@playoff_players = @players.map { |p| p[:player_id].to_s }

    # Full roster (names + photos + jersey numbers)
    @roster = NbaStatsService.team_roster(
			team_id: team_id,
			season: "2025-26"
		)

		# Get playoff opponent for the selected round
		@playoff_opponent = NbaStatsService.playoff_opponent(
			team_id: team_id,
			season: "2025-26",
			poround: selected_round
		)
	end
end
