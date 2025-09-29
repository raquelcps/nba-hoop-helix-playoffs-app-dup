class FinalsController < ApplicationController
	def show
	  @player = Player.find_by(:person_id => params[:person_id])

      #NBA.com common player data
      po_player_data = HTTParty.get("http://stats.nba.com/stats/commonplayerinfo?LeagueID=00&PlayerID=#{@player.person_id}&SeasonType=Playoffs")

      a = po_player_data.body
      b = a["resultSets"]
      c = b[0]
      d = c["headers"]
      e = c["rowSet"]

      @po_playerdata = []
      "ZIPPING!!"
      e.each do |row|
      	hash = Hash[*d.zip(row).flatten]
      	@po_playerdata << hash 
      end

      #NBA.com player dashboard totals
      @po_player_dashboard_totals = HTTParty.get("http://stats.nba.com/stats/playerdashboardbygeneralsplits?DateFrom=&DateTo=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerID=#{@player.person_id}&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&VsConference=&VsDivision=")
        @rd_player_dashboard_totals = HTTParty.get("http://stats.nba.com/stats/playerdashboardbygeneralsplits?DateFrom=04/18/2015&DateTo=05/02/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerID=#{@player.person_id}&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&VsConference=&VsDivision=")
      	@sf_player_dashboard_totals = HTTParty.get("http://stats.nba.com/stats/playerdashboardbygeneralsplits?DateFrom=05/03/2015&DateTo=05/17/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerID=#{@player.person_id}&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&VsConference=&VsDivision=")
      	@cf_player_dashboard_totals = HTTParty.get("http://stats.nba.com/stats/playerdashboardbygeneralsplits?DateFrom=05/19/2015&DateTo=05/27/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerID=#{@player.person_id}&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&VsConference=&VsDivision=")
      	@f_player_dashboard_totals = HTTParty.get("http://stats.nba.com/stats/playerdashboardbygeneralsplits?DateFrom=06/04/2015&DateTo=06/19/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlayerID=#{@player.person_id}&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&VsConference=&VsDivision=")
      
      a = @f_player_dashboard_totals.body
      b = a["resultSets"]
      c = b[0] #specific array for totals    
      d = c["headers"]
      e = c["rowSet"]

      @po_PlayerTotalsdata = []
      "ZIPPING!!"
      e.each do |row|
        hash = Hash[*d.zip(row).flatten]
     # keys_to_delete.each do |key|
     #   hash.delete(key)
     # end
        @po_PlayerTotalsdata << hash 
      end

      #NBA.com passes made 
      @po_player_passes = HTTParty.get("http://stats.nba.com/stats/playerdashptpass?DateFrom=06/04/2015&DateTo=06/19/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&Month=0&OpponentTeamID=0&Outcome=&PerMode=Totals&Period=0&PlayerID=#{@player.person_id}&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&TeamID=0&VsConference=&VsDivision=")
      
      a = @po_player_passes.body
      b = a["resultSets"]
      c = b[0] #gets all PassesMade from playerA to teammates
      d = c["headers"]
      e = c["rowSet"]
      g = e.each do |row|
     	row.each do |item| 

     	end
      end
      #How do i do this so that the first row references playerA only, but the following nodes are teammates passed to
      keys_to_delete = ["TEAM_NAME", "TEAM_ID", "PASS_TYPE", "G"]
      @po_data = []
      "ZIPPING!!"
      e.each do |row|
    	hash = Hash[*d.zip(row).flatten]
    	# keys_to_delete.each do |key|
    	# 	hash.delete(key)
    	# end
    	@po_data << hash 
      end


      #Added each do for player total passes
      @po_player_total_passes = []
      @po_data.each do |passes|
      	@po_player_total_passes << passes["PASS"]
      end

      recc = b[1] #gets all PassesReceived by playerA from teammates
      recd = recc["headers"]        
      rece = recc["rowSet"]

      @po_ReceivedData = []
      "ZIPPING!!"
      rece.each do |row|    	
        hash = Hash[*d.zip(row).flatten]
         # keys_to_delete.each do |key|
         #   hash.delete(key)
         # end
        @po_ReceivedData << hash 
      end

      @po_player_total_ast_recd = []
      @po_player_total_pass_recd = []
      @po_ReceivedData.each do |passes|
 	    @po_player_total_ast_recd << passes["AST"]
 	    @po_player_total_pass_recd << passes["PASS"]
      end

      #NBA.com player's team totals data
      po_player_team_data = HTTParty.get("http://stats.nba.com/stats/teamdashboardbygeneralsplits?DateFrom=06/04/2015&DateTo=06/19/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&TeamID=#{@po_playerdata[0]["TEAM_ID"]}&VsConference=&VsDivision=")
    
      a = po_player_team_data.body
      b = a["resultSets"]
      c = b[0] #overall team dashboard
      d = c["headers"]
      e = c["rowSet"]

      @po_playerteamdata = []
      "ZIPPING!!"
      e.each do |row|
    	hash = Hash[*d.zip(row).flatten]

    	@po_playerteamdata << hash 
      end

       # Team Passing Totals 
       po_team_passing = HTTParty.get("http://stats.nba.com/stats/teamdashptpass?DateFrom=06/04/2015&DateTo=06/19/2015&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=Totals&Period=0&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&TeamID=#{@po_playerdata[0]["TEAM_ID"]}&VsConference=&VsDivision=")
       a = po_team_passing.body
       b = a["resultSets"]
       c = b[0]
       d = c["headers"]
       e = c["rowSet"]
         # p team_passing
       @po_team_passes_per_player = []
       e.each do |row|
     	 hash = Hash[*d.zip(row).flatten]
     	 @po_team_passes_per_player << hash 
       end
       @po_team_passes_total = []
       # @team_assist_total = []
       @po_team_passes_per_player.each do |player|
     	 @po_team_passes_total << player["PASS"]
         # @team_assist_total << player["AST"]
       end


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

       @po_team_touches_total = @po_team_touches_array.select {|team| team["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"] }

       #Player Touches
       po_player_touches = HTTParty.get("http://stats.nba.com/js/data/sportvu/2014/touchesDataPost.json").body["resultSets"][0]["rowSet"]

       @po_player_touches_total = po_player_touches.select{ |player| player[0].to_i == @po_playerdata[0]["PERSON_ID"] }
     	
     #Team roster - Used teamplayerdashboard instead of commonteamroster to show only players who have played in playoffs
       po_team_rosters = HTTParty.get("http://stats.nba.com/stats/teamplayerdashboard?DateFrom=&DateTo=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=PerGame&Period=0&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&TeamID=#{@po_playerdata[0]["TEAM_ID"]}&VsConference=&VsDivision=")
       a = po_team_rosters.body
       b = a["resultSets"]
       c = b[1]
       d = c["headers"]
       e = c["rowSet"]

       @po_team_rosters_array = []
       e.each do |row|
       	hash = Hash[*d.zip(row).flatten]
       	@po_team_rosters_array << hash 
       end

       #Teams in playoffs
       @po_teams = []
       @po_team_touches_array.each do |team|
       	@po_teams << team["TEAM_ID"]
       end
		

#Touches by playoff round using game logs

#Finals Gm 6
f_gm6_boxscore = HTTParty.get("http://stats.nba.com/stats/boxscoreplayertrackv2?EndPeriod=10&EndRange=55800&GameID=0041400406&RangeType=2&Season=2014-15&SeasonType=Playoffs&StartPeriod=1&StartRange=0")
a = f_gm6_boxscore.body
b = a["resultSets"]
c = b[0] #playertrack
d = c["headers"]
e = c["rowSet"]

@f_gm6_boxscore_array = []
e.each do |row|
  hash = Hash[*d.zip(row).flatten]
  @f_gm6_boxscore_array << hash 
end

@f_gm6_player_touches = @f_gm6_boxscore_array.select { |player| player["PLAYER_ID"].to_i == @po_playerdata[0]["PERSON_ID"]}

@f_gm6_team_touches = @f_gm6_boxscore_array.select { |player| player["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"]}

#Finals Gm 5
f_gm5_boxscore = HTTParty.get("http://stats.nba.com/stats/boxscoreplayertrackv2?EndPeriod=10&EndRange=55800&GameID=0041400405&RangeType=2&Season=2014-15&SeasonType=Playoffs&StartPeriod=1&StartRange=0")
a = f_gm5_boxscore.body
b = a["resultSets"]
c = b[0] #playertrack
d = c["headers"]
e = c["rowSet"]

@f_gm5_boxscore_array = []
e.each do |row|
  hash = Hash[*d.zip(row).flatten]
  @f_gm5_boxscore_array << hash 
end

@f_gm5_player_touches = @f_gm5_boxscore_array.select { |player| player["PLAYER_ID"].to_i == @po_playerdata[0]["PERSON_ID"]}

@f_gm5_team_touches = @f_gm5_boxscore_array.select { |player| player["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"]}

#Finals Gm 4
f_gm4_boxscore = HTTParty.get("http://stats.nba.com/stats/boxscoreplayertrackv2?EndPeriod=10&EndRange=55800&GameID=0041400404&RangeType=2&Season=2014-15&SeasonType=Playoffs&StartPeriod=1&StartRange=0")
a = f_gm4_boxscore.body
b = a["resultSets"]
c = b[0] #playertrack
d = c["headers"]
e = c["rowSet"]

@f_gm4_boxscore_array = []
e.each do |row|
  hash = Hash[*d.zip(row).flatten]
  @f_gm4_boxscore_array << hash 
end

@f_gm4_player_touches = @f_gm4_boxscore_array.select { |player| player["PLAYER_ID"].to_i == @po_playerdata[0]["PERSON_ID"]}

@f_gm4_team_touches = @f_gm4_boxscore_array.select { |player| player["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"]}

#Finals Gm 3
f_gm3_boxscore = HTTParty.get("http://stats.nba.com/stats/boxscoreplayertrackv2?EndPeriod=10&EndRange=55800&GameID=0041400403&RangeType=2&Season=2014-15&SeasonType=Playoffs&StartPeriod=1&StartRange=0")
a = f_gm3_boxscore.body
b = a["resultSets"]
c = b[0] #playertrack
d = c["headers"]
e = c["rowSet"]

@f_gm3_boxscore_array = []
e.each do |row|
  hash = Hash[*d.zip(row).flatten]
  @f_gm3_boxscore_array << hash 
end

@f_gm3_player_touches = @f_gm3_boxscore_array.select { |player| player["PLAYER_ID"].to_i == @po_playerdata[0]["PERSON_ID"]}

@f_gm3_team_touches = @f_gm3_boxscore_array.select { |player| player["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"]}

@f_gm3_team_touches_array = []
@f_gm3_team_touches.each do |hash|
  @f_gm3_team_touches_array << hash["TCHS"]
end




#Finals game 2
f_gm2_boxscore = HTTParty.get("http://stats.nba.com/stats/boxscoreplayertrackv2?EndPeriod=10&EndRange=55800&GameID=0041400402&RangeType=2&Season=2014-15&SeasonType=Playoffs&StartPeriod=1&StartRange=0")
a = f_gm2_boxscore.body
b = a["resultSets"]
c = b[0] #playertrack
d = c["headers"]
e = c["rowSet"]

@f_gm2_boxscore_array = []
e.each do |row|
  hash = Hash[*d.zip(row).flatten]
  @f_gm2_boxscore_array << hash 
end

@f_gm2_player_touches = @f_gm2_boxscore_array.select { |player| player["PLAYER_ID"].to_i == @po_playerdata[0]["PERSON_ID"]}

@f_gm2_team_touches = @f_gm2_boxscore_array.select { |player| player["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"]}


#Finals game 1
f_gm1_boxscore = HTTParty.get("http://stats.nba.com/stats/boxscoreplayertrackv2?EndPeriod=10&EndRange=55800&GameID=0041400401&RangeType=2&Season=2014-15&SeasonType=Playoffs&StartPeriod=1&StartRange=0")
a = f_gm1_boxscore.body
b = a["resultSets"]
c = b[0] #playertrack
d = c["headers"]
e = c["rowSet"]

@f_gm1_boxscore_array = []
e.each do |row|
  hash = Hash[*d.zip(row).flatten]
  @f_gm1_boxscore_array << hash 
end

@f_gm1_player_touches = @f_gm1_boxscore_array.select { |player| player["PLAYER_ID"].to_i == @po_playerdata[0]["PERSON_ID"]}

@f_gm1_team_touches = @f_gm1_boxscore_array.select { |player| player["TEAM_ID"].to_i == @po_playerdata[0]["TEAM_ID"]}

#Finals player total touches
@finals_player_touches_array = []
@f_gm6_player_touches.each do |gm6|
  @finals_player_touches_array << gm6["TCHS"]
end
@f_gm5_player_touches.each do |gm5|
  @finals_player_touches_array << gm5["TCHS"]
end
@f_gm4_player_touches.each do |gm4|
  @finals_player_touches_array << gm4["TCHS"]
end
@f_gm3_player_touches.each do |gm3|
  @finals_player_touches_array << gm3["TCHS"]
end
@f_gm2_player_touches.each do |gm2|
  @finals_player_touches_array << gm2["TCHS"]
end
@f_gm1_player_touches.each do |gm1|
  @finals_player_touches_array << gm1["TCHS"]
end

#Finals team total touches
@finals_team_touches_array = []
@f_gm6_team_touches.each do |gm6|
  @finals_team_touches_array << gm6["TCHS"]
end
@f_gm5_team_touches.each do |gm5|
  @finals_team_touches_array << gm5["TCHS"]
end
@f_gm4_team_touches.each do |gm4|
  @finals_team_touches_array << gm4["TCHS"]
end
@f_gm3_team_touches.each do |gm3|
  @finals_team_touches_array << gm3["TCHS"]
end
@f_gm2_team_touches.each do |gm2|
  @finals_team_touches_array << gm2["TCHS"]
end
@f_gm1_team_touches.each do |gm1|
  @finals_team_touches_array << gm1["TCHS"]
end
	
  end
end
