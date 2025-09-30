class TeamsController < ApplicationController

	def index
		@teams = Team.all
	end

	def show
		@team = Team.find_by(:team_id => params[:team_id])
    puts "Debugging message team: #{@team}"
		@teams = Team.all
    puts "Debugging message teams: #{@teams}"

		# Get team touches of all playoff teams
    league_response = HTTParty.get(
			"https://stats.nba.com/stats/leaguedashptstats",
			query: {
				College: "",
				Conference: "",
				Country: "",
				DateFrom: "",
				DateTo: "",
				Division: "",
				DraftPick: "",
				DraftYear: "",
				GameScope: "",
				Height: "",
				ISTRound: "",
				LastNGames: 0,
				LeagueID: "00",
				Location: "",
				Month: 0,
				OpponentTeamID: 0,
				Outcome: "",
				PORound: 0,
				PerMode: "PerGame",
				PlayerExperience: "",
				PlayerOrTeam: "Team",
				PlayerPosition: "",
				PtMeasureType: "Possessions",
				Season: "2014-15",
				SeasonSegment: "",
				SeasonType: "Playoffs",
				StarterBench: "",
				TeamID: 0,
				VsConference: "",
				VsDivision: "",
				Weight: ""
			},
			headers: {
				"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
				"Accept" => "application/json, text/plain, */*",
				"Referer" => "https://stats.nba.com/"
			}
		)

		response_body = league_response.body
		puts "Debugging message response body: #{response_body}"
		parsed = JSON.parse(league_response.body)
		team_touches = parsed["resultSets"][0]["rowSet"]
		puts "parsed:"
		puts parsed
		puts "team_touches:"
		puts team_touches
    
		#Team touches
		# Not sure what I'm doing here with assigning po_team_touches to league_response. What's the point?
		po_team_touches = league_response
		b = po_team_touches["resultSets"]
		c = b[0]
		d = c["headers"]
		e = c["rowSet"]

		@po_team_touches_array = []
			e.each do |row|
			hash = Hash[*d.zip(row).flatten]
			@po_team_touches_array << hash
		end
		puts "Debugging message po_team_touches_array: #{@po_team_touches_array}"

		##########
		#Team roster - Used teamplayerdashboard instead of commonteamroster to show only players who have played in playoffs
		player_response = HTTParty.get(
			"https://stats.nba.com/stats/teamplayerdashboard",
			query: {
				DateFrom: "",
				DateTo: "",
				GameSegment: "",
				LastNGames: 0,
				LeagueID: "00",
				Location: "",
				MeasureType: "Base",
				Month: 0,
				OpponentTeamID: 0,
				Outcome: "",
				PaceAdjust: "N",
				PerMode: "Totals",
				Period: 0,
				PlusMinus: "N",
				Rank: "N",
				Season: "2014-15",
				SeasonSegment: "",
				SeasonType: "Playoffs",
				TeamID: "#{@team.team_id}",
				VsConference: "",
				VsDivision: ""
			},
			headers: {
				"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
				"Accept" => "application/json, text/plain, */*",
				"Referer" => "https://stats.wnba.com/"
			}
		)

		parsed = JSON.parse(player_response.body)
		roster = parsed["resultSets"][0]["rowSet"]
		puts "Debugging message roster: #{roster}"

		po_team_rosters = player_response
		# puts "Debugging message po_team_rosters: #{po_team_rosters}"
		b = po_team_rosters["resultSets"]
		c = b[1] #Player Totals array
		d = c["headers"]
		e = c["rowSet"]

		@po_team_rosters_array = []
		e.each do |row|
			hash = Hash[*d.zip(row).flatten]
			@po_team_rosters_array << hash
		end
		puts "Debugging message po_team_rosters_array: #{@po_team_rosters_array}"

		@po_team_roster_playerid = []
		@po_team_rosters_array.each do |hash|
			@po_team_roster_playerid << hash["PLAYER_ID"]
		end
		puts "Debugging message po_team_roster_playerid: #{@po_team_roster_playerid}"

		ateam = po_team_rosters
		bteam = ateam["resultSets"]
		cteam = bteam[0]
		dteam = cteam["headers"]
		eteam = cteam["rowSet"]
		puts "debugging message ateam: #{ateam}"
		puts "debugging message eteam: #{eteam}"

		@po_team_totals_array = []
		eteam.each do |row|
			hash = Hash[*dteam.zip(row).flatten]
			@po_team_totals_array << hash
		end

		p "team totals:"
		p @po_team_totals_array
	end #Show
end
