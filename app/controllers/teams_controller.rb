class TeamsController < ApplicationController
	before_action :set_playoff_teams

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

    # Full roster (names + photos + jersey numbers)
    @roster = NbaStatsService.team_roster(team_id: team_id, season: "2024-25")
	end

	private

  def set_playoff_teams
    @teams ||= NbaStatsService.playoff_teams(season: "2024-25")
		puts "********* Debugging message from before_action @teams:"
		puts @teams.inspect
  end
end
