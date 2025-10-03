class TeamsController < ApplicationController
	def index
	end

	def show
		team_id = params[:id]
		puts "debugging message teams#show team_id:" 
		puts team_id

    # Team totals for grid
    @team_totals = NbaStatsService.team_totals(team_id: team_id, season: "2024-25")

    # Player totals for top 5 lists
    @players = NbaStatsService.team_players(team_id: team_id, season: "2024-25")
		@playoff_players = NbaStatsService.team_players(team_id: team_id, season: "2024-25", poround: 0).map { |p| p[:player_id].to_s }

    # Full roster (names + photos + jersey numbers)
    @roster = NbaStatsService.team_roster(team_id: team_id, season: "2024-25")
		puts "********* Debugging message from teams#show @roster:"
		puts @roster.inspect
	end
end
