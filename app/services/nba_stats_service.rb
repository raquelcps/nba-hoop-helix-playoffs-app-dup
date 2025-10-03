require "httparty"

class NbaStatsService
  BASE_URL = "https://stats.nba.com/stats"
  DEFAULT_HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    "Accept" => "application/json, text/plain, */*",
    "Accept-Encoding" => "gzip, deflate, br",
    "Connection" => "keep-alive",
    "Referer" => "https://www.nba.com/"
  }

  # -------------------
  # Public API methods
  # -------------------

  def self.playoff_teams(season: "2024-25")
    Rails.cache.fetch("nba/playoff_teams/#{season}", expires_in: 12.hours) do
      response = get_json("leaguedashteamstats", {
        Season: season,
        SeasonType: "Playoffs",
        PerMode: "Totals",
        TeamID: 0,
        LastNGames: 0,
        Month: 0,
        PORound: 0,
        OpponentTeamID: 0,
        Period: 0,
        LeagueID: "00",
        MeasureType: "Base",
        PaceAdjust: "N",
        PlusMinus: "N",
        Rank: "N",
      })
      normalize_result(response).map do |row|
        {
          team_id: row["TEAM_ID"],
          team_name: row["TEAM_NAME"],
          wins: row["W"],
          losses: row["L"],
          logo_url: team_logo_url(row["TEAM_ID"])
        }
      end
    end
  end

  def self.team_totals(team_id:, season: "2024-25", poround: 0)
    Rails.cache.fetch("nba/team_totals/#{team_id}/#{season}/#{poround}", expires_in: 12.hours) do
      response = get_json("leaguedashteamstats", {
        Season: season,
        SeasonType: "Playoffs",
        PerMode: "Totals",
        TeamID: team_id,
        LastNGames: 0,
        Month: 0,
        PORound: poround,
        OpponentTeamID: 0,
        Period: 0,
        LeagueID: "00",
        MeasureType: "Base",
        PaceAdjust: "N",
        PlusMinus: "N",
        Rank: "N",
      })
      normalize_result(response).first
    end
  end

  def self.team_players(team_id:, season: "2024-25", poround: 0)
    Rails.cache.delete("nba/team_players/#{team_id}/#{season}/#{poround}") #temp delete cache for testing
    Rails.cache.fetch("nba/team_players/#{team_id}/#{season}/#{poround}", expires_in: 1.minute) do #was 12.hours
      response = get_json("leaguedashplayerstats", {
        Season: season,
        SeasonType: "Playoffs",
        PerMode: "Totals",
        TeamID: team_id,
        LastNGames: 0,
        Month: 0,
        PORound: poround,
        OpponentTeamID: 0,
        Period: 0,
        LeagueID: "00",
        MeasureType: "Base",
        PaceAdjust: "N",
        PlusMinus: "N",
        Rank: "N",
        ActiveRoster: 0
      })
      stats = normalize_result(response)

      # Get roster
      roster = team_roster(team_id: team_id, season: season)

      # Merge stats with roster info
      stats.map do |row|
        roster_info = roster.find { |r| r[:player_id].to_s == row["PLAYER_ID"].to_s }

        {
          player_id: row["PLAYER_ID"],
          player_name: row["PLAYER_NAME"],
          age: row["AGE"],
          gp: row["GP"],
          w: row["W"],
          l: row["L"],
          w_pct: row["W_PCT"],
          min: row["MIN"],
          fgm: row["FGM"],
          fga: row["FGA"],
          fg_pct: row["FG_PCT"],
          fg3m: row["FG3M"],
          fg3a: row["FG3A"],
          fg3_pct: row["FG3_PCT"],
          ftm: row["FTM"],
          fta: row["FTA"],
          ft_pct: row["FT_PCT"],
          oreb: row["OREB"],
          dreb: row["DREB"],
          reb: row["REB"],
          ast: row["AST"],
          tov: row["TOV"],
          stl: row["STL"],
          blk: row["BLK"],
          blka: row["BLKA"],
          pf: row["PF"],
          pfd: row["PFD"],
          pts: row["PTS"],
          photo_url: player_photo_url(row["PLAYER_ID"]),

          # now pulled from roster
          jersey: roster_info&.dig(:jersey),
          position: roster_info&.dig(:position),
          exp: roster_info&.dig(:exp),
          height: roster_info&.dig(:height),
          weight: roster_info&.dig(:weight),
        }
      end
    end
  end

  def self.team_roster(team_id:, season: "2024-25")
    Rails.cache.delete("nba/team_roster/#{team_id}/#{season}") #temp delete cache for testing
    Rails.cache.fetch("nba/team_roster/#{team_id}/#{season}", expires_in: 1.minute) do #was 12.hours
      response = get_json("commonteamroster", {
        Season: season,
        TeamID: team_id
      })
      normalize_result(response).map do |row|
        {
          player_id: row["PLAYER_ID"],
          player_name: row["PLAYER"],
          jersey: row["NUM"],
          position: row["POSITION"],
          exp: row["EXP"],
          height: row["HEIGHT"],
          weight: row["WEIGHT"],
          photo_url: player_photo_url(row["PLAYER_ID"])
        }
      end
    end
  end

  # -------------------
  # Helpers
  # -------------------

  def self.get_json(endpoint, params = {})
    url = "#{BASE_URL}/#{endpoint}"
    response = HTTParty.get(url, query: params, headers: DEFAULT_HEADERS)
    if response.code == 200
        puts "Debugging message response code: #{response.code}"
      else
        Rails.logger.error "API error for player touches: #{response.code} - #{response.body}"
      end
    puts "NBA API response for #{endpoint}:"
    puts response
    puts "url:"
    puts url
    puts "params:"
    puts params.inspect
    JSON.parse(response.body)
  end

  def self.normalize_result(response)
    result_set = response["resultSets"].first
    headers = result_set["headers"]
    result_set["rowSet"].map { |row| headers.zip(row).to_h }
    # Rails.logger.debug "Keys in normalize_result: #{rows.first.keys.inspect}" if rows.any?
  end

  def self.team_logo_url(team_id)
    "https://cdn.nba.com/logos/nba/#{team_id}/primary/L/logo.svg"
  end

  def self.player_photo_url(player_id)
    "https://cdn.nba.com/headshots/nba/latest/260x190/#{player_id}.png"
  end
end
