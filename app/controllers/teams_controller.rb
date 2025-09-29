class TeamsController < ApplicationController

	def index
		@teams = Team.all
          @hi = "hi"
          puts "Debugging message: #{@hi}"
          puts "Debugging message: #{@teams}"
	end

	def show
		@team = Team.find_by(:team_id => params[:team_id])

		@teams = Team.all

      	 #Team touches
             po_team_touches = HTTParty.get("http://stats.nba.com/js/data/sportvu/2014/touchesTeamDataPost.json")
             a = po_team_touches.body
             b = a["resultSets"]
             c = b[0]
             d = c["headers"]
             e = c["rowSet"]

             @po_team_touches_array = []
             e.each do |row|
           	 hash = Hash[*d.zip(row).flatten]
           	 @po_team_touches_array << hash 
             end


      	 #Team roster - Used teamplayerdashboard instead of commonteamroster to show only players who have played in playoffs
             po_team_rosters = HTTParty.get("http://stats.nba.com/stats/teamplayerdashboard?DateFrom=&DateTo=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&TeamID=#{@team.team_id}&VsConference=&VsDivision=")
             a = po_team_rosters.body
             b = a["resultSets"]
             c = b[1] #Player Totals array
             d = c["headers"]
             e = c["rowSet"]

             @po_team_rosters_array = []
             e.each do |row|
             	hash = Hash[*d.zip(row).flatten]
             	@po_team_rosters_array << hash 
             end

             @po_team_roster_playerid = []
             @po_team_rosters_array.each do |hash|
                  @po_team_roster_playerid << hash["PLAYER_ID"]

             end

             ateam = po_team_rosters.body
             bteam = ateam["resultSets"]
             cteam = bteam[0]
             dteam = cteam["headers"]
             eteam = cteam["rowSet"]

             @po_team_totals_array = []
             eteam.each do |row|
                  hash = Hash[*dteam.zip(row).flatten]
                  @po_team_totals_array << hash 
            end

            p "team totals"
            p @po_team_totals_array

    




	end #Show

end
