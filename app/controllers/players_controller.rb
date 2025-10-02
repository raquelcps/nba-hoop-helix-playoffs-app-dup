class PlayersController < ApplicationController

	def index
    
	end

	def show
    @player = Player.find_by(:person_id => params[:person_id])
    puts "Debugging message @player: #{@player.person_id}, #{@player.name}"

    #NBA.com common player data
    player_response = HTTParty.get(
      "https://stats.nba.com/stats/commonplayerinfo",
      query: {
        LeagueID: "00",   # 10 = WNBA, 00 = NBA
        PlayerID: "#{@player.person_id}",
        #TODO are these two params needed for this endpoint?
        Season: "2014-15",
        SeasonType: "Playoffs",
      },
      headers: {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        "Accept" => "application/json, text/plain, */*",
        "Referer" => "https://stats.wnba.com/"
      }
    )

    puts "player_response: #{player_response}"
    po_player_data = player_response
    puts "po_player_data: #{po_player_data}"
    ab = po_player_data["resultSets"]
    puts "po_player_data resultsets: #{ab}"
    ac = ab[0]
    ad = ac["headers"]
    ae = ac["rowSet"]

    @po_playerdata = []
      ae.each do |row|
      hash = Hash[*ad.zip(row).flatten]
      @po_playerdata << hash 
    end
    puts "+++++++++Debugging message po_playerdata: #{@po_playerdata}"

    #NBA.com player dashboard totals
    base_uri = "https://stats.nba.com/stats/"
    query = {
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
      PlayerID: "#{@player.person_id}",
      PlusMinus: "N",
      PORound: 0,
      Rank: "N",
      Season: "2014-15",
      SeasonSegment: "",
      SeasonType: "Playoffs",
      VsConference: "",
      VsDivision: ""
    }
    headers = {
      "Accept" => "application/json, text/plain, */*",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      "Referer" => "https://www.nba.com/",
      "Origin" => "https://www.nba.com",
      "Connection" => "keep-alive"
    }

    @po_player_dashboard_totals = HTTParty.get("#{base_uri}playerdashboardbygeneralsplits", query: query, headers: headers)
    puts "Status code @po_player_dashboard_totals: #{@po_player_dashboard_totals.code}"
    puts "Headers: #{@po_player_dashboard_totals.headers.inspect}"
    puts "Body preview: #{@po_player_dashboard_totals.body[0..500]}"


    @rd_player_dashboard_totals = HTTParty.get("#{base_uri}playerdashboardbygeneralsplits", query: query.merge(DateFrom: "04/18/2015", DateTo: "05/02/2015"), headers: headers)
    puts "Status code @rd_player_dashboard_totals: #{@rd_player_dashboard_totals.code}"
    puts "Headers: #{@rd_player_dashboard_totals.headers.inspect}"
    puts "Body preview: #{@rd_player_dashboard_totals.body[0..500]}"

    @sf_player_dashboard_totals = HTTParty.get("#{base_uri}playerdashboardbygeneralsplits", query: query.merge(DateFrom: "05/03/2015", DateTo: "05/17/2015"), headers: headers)

    @cf_player_dashboard_totals = HTTParty.get("#{base_uri}playerdashboardbygeneralsplits", query: query.merge(DateFrom: "05/19/2015", DateTo: "05/27/2015"), headers: headers)

    @f_player_dashboard_totals = HTTParty.get("#{base_uri}playerdashboardbygeneralsplits", query: query.merge(DateFrom: "06/04/2015", DateTo: "06/19/2015"), headers: headers)
    puts "debugging message @po_player_dashboard_totals:"
    puts @po_player_dashboard_totals
    bb = @po_player_dashboard_totals["resultSets"]
    puts "debugging message @po_player_dashboard_totals resultsets:"
    puts bb
    bc = bb[0] #specific array for totals
    puts "debugging messagebc:"
    puts bc
    bd = bc["headers"]
    be = bc["rowSet"]

    @po_PlayerTotalsdata = []
    "ZIPPING!!"
    be.each do |row|
      hash = Hash[*bd.zip(row).flatten]
      @po_PlayerTotalsdata << hash 
    end
    puts "debugging message @po_PlayerTotalsdata:"
    puts @po_PlayerTotalsdata

    #NBA.com passes made 
    @po_player_passes = HTTParty.get("#{base_uri}playerdashptpass", query: query, headers: headers)
    cb = @po_player_passes["resultSets"]
    puts "debugging message cb:"
    puts cb
    cc = cb[0] #gets all PassesMade from playerA to teammates
    puts "debugging message cc:"
    puts cc
    cd = cc["headers"]
    puts "debugging message cd:"
    puts cd
    ce = cc["rowSet"]
    puts "debugging message ce:"
    puts ce.first.inspect
    g = ce.each do |row|
      row.each do |item| 
    end
    puts "debugging message g:"
    puts g
    end
    #How do i do this so that the first row references playerA only, but the following nodes are teammates passed to
    keys_to_delete = ["TEAM_NAME", "TEAM_ID", "PASS_TYPE", "G"]
    @po_data = []
    "ZIPPING!!"
    ce.each do |row|
      hash = Hash[*cd.zip(row).flatten]
      @po_data << hash 
    end


    #Added each do for player total passes
    @po_player_total_passes = []
    @po_data.each do |passes|
      @po_player_total_passes << passes["PASS"]
    end

    recc = cb[1] #gets all PassesReceived by playerA from teammates
    recd = recc["headers"]        
    rece = recc["rowSet"]

    @po_ReceivedData = []
    "ZIPPING!!"
    rece.each do |row|    	
      hash = Hash[*recd.zip(row).flatten]
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
    po_player_team_data = HTTParty.get("#{base_uri}teamdashboardbygeneralsplits", query: query.merge(TeamID: @po_playerdata[0]["TEAM_ID"]), headers: headers)
    db = po_player_team_data["resultSets"]
    dc = db[0] #overall team dashboard
    dd = dc["headers"]
    de = dc["rowSet"]
    puts "debugging message de:"
    puts de

    @po_playerteamdata = []
    "ZIPPING!!"
    de.each do |row|
      hash = Hash[*dd.zip(row).flatten]
      @po_playerteamdata << hash
    end
    puts "debugging message @po_playerteamdata:"
    puts @po_playerteamdata


    # Team Passing Totals 
    po_team_passing = HTTParty.get("#{base_uri}teamdashptpass", query: query.merge(TeamID: @po_playerdata[0]["TEAM_ID"]), headers: headers)
    eb = po_team_passing["resultSets"]
    ec = eb[0]
    ed = ec["headers"]
    ee = ec["rowSet"]
    # p team_passing
    @po_team_passes_per_player = []
    ee.each do |row|
    hash = Hash[*ed.zip(row).flatten]
    @po_team_passes_per_player << hash 
    end
    @po_team_passes_total = []
    # @team_assist_total = []
    @po_team_passes_per_player.each do |player|
    @po_team_passes_total << player["PASS"]
      # @team_assist_total << player["AST"]
    end


    #Team touches
    po_team_touches_response = HTTParty.get("#{base_uri}leaguedashptstats", query: {
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
      PerMode: "Totals",
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
    headers: headers
    )

    headers = po_team_touches_response["resultSets"][0]["headers"]
    row_set = po_team_touches_response["resultSets"][0]["rowSet"]

    # Find the index for "TCH_TOT"
    tch_tot_index = headers.index("TCH_TOT")

    # Filter for the relevant team row (adjust index as needed)
    @po_team_touches_total = row_set.select { |team| team[headers.index("TEAM_ID")].to_i == @po_playerdata[0]["TEAM_ID"].to_i }

    # Pass the index to the view
    @tch_tot_index = tch_tot_index

    p "po team touches total"
    p @po_team_touches_total

    #Player Touches
    begin
      po_player_touches_response = HTTParty.get("#{base_uri}leaguedashptstats", query: {
        LeagueID: "00",
        Season: "2014-15",
        SeasonType: "Playoffs",
        PerMode: "Totals",
        PtMeasureType: "Possessions",
        PlayerOrTeam: "Player",
        LastNGames: 0,
        Month: 0,
        PORound: 0,
        TeamID: 0,
        OpponentTeamID: 0
      },
      headers: headers,
      timeout: 20
      )
      puts "****Code: #{po_player_touches_response.code}"
      puts "*****Headers: #{po_player_touches_response.headers.inspect}"
      puts "******Body preview: #{po_player_touches_response.body[0..500]}"

      if po_player_touches_response.code == 200 && po_player_touches_response.parsed_response.is_a?(Hash)
        result_sets = po_player_touches_response["resultSets"]
        if result_sets && result_sets[0]
          player_headers = result_sets[0]["headers"]
          player_row_set = result_sets[0]["rowSet"]
          touches_index = player_headers.index("TOUCHES")
          @po_player_touches_total = player_row_set.select { |player| player[headers.index("PLAYER_ID")].to_i == @po_playerdata[0]["PERSON_ID"].to_i }
          @touches_index = touches_index
          puts "po player touches:"
          puts player_row_set.inspect
        else
          Rails.logger.error "Unexpected API format for player touches: #{po_player_touches_response.body}"
          @po_player_touches_total = []
          @touches_index = nil
        end
      else
        Rails.logger.error "API error for player touches: #{po_player_touches_response.code} - #{po_player_touches_response.body}"
        @po_player_touches_total = []
        @touches_index = nil
      end
    rescue => e
      Rails.logger.error "HTTParty error: #{e.message}"
      @po_player_touches_total = []
      @touches_index = nil
    end
    puts @po_playerdata[0]["PERSON_ID"].inspect

    #Team roster - Used teamplayerdashboard instead of commonteamroster to show only players who have played in playoffs
    #    po_team_rosters = HTTParty.get("http://stats.nba.com/stats/teamplayerdashboard?DateFrom=&DateTo=&GameSegment=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&Month=0&OpponentTeamID=0&Outcome=&PaceAdjust=N&PerMode=PerGame&Period=0&PlusMinus=N&Rank=N&Season=2014-15&SeasonSegment=&SeasonType=Playoffs&TeamID=#{@po_playerdata[0]["TEAM_ID"]}&VsConference=&VsDivision=")
    #    a = po_team_rosters.body
    #    b = a["resultSets"]
    #    c = b[1]
    #    d = c["headers"]
    #    e = c["rowSet"]

    #    @po_team_rosters_array = []
    #    e.each do |row|
    #    	hash = Hash[*d.zip(row).flatten]
    #    	@po_team_rosters_array << hash 
    #    end

    #    #Teams in playoffs
    #    @po_teams = []
    #    @po_team_touches_array.each do |team|
    #    	@po_teams << team["TEAM_ID"]
    #    end
		# p @po_teams

	end #Show


end
