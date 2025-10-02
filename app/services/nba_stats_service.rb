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
      puts "Debugging message response in playoff_teams:"
      puts response.inspect

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

  def self.team_totals(team_id:, season: "2024-25")
    Rails.cache.fetch("nba/team_totals/#{team_id}/#{season}", expires_in: 12.hours) do
      response = get_json("leaguedashteamstats", {
        Season: season,
        SeasonType: "Playoffs",
        PerMode: "Totals",
        TeamID: team_id,
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
      normalize_result(response).first
    end
  end

  def self.team_players(team_id:, season: "2024-25")
    Rails.cache.fetch("nba/team_players/#{team_id}/#{season}", expires_in: 12.hours) do
      response = get_json("leaguedashplayerstats", {
        Season: season,
        SeasonType: "Playoffs",
        PerMode: "Totals",
        TeamID: team_id,
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
        ActiveRoster: 0
      })
      normalize_result(response).map do |row|
        {
          player_id: row["PLAYER_ID"],
          player_name: row["PLAYER_NAME"],
          pts: row["PTS"],
          ast: row["AST"],
          reb: row["REB"],
          min: row["MIN"],
          photo_url: player_photo_url(row["PLAYER_ID"])
        }
      end
    end
  end

  def self.team_roster(team_id:, season: "2024-25")
    Rails.cache.fetch("nba/team_roster/#{team_id}/#{season}", expires_in: 12.hours) do
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
  end

  def self.team_logo_url(team_id)
    "https://cdn.nba.com/logos/nba/#{team_id}/primary/L/logo.svg"
  end

  def self.player_photo_url(player_id)
    "https://cdn.nba.com/headshots/nba/latest/260x190/#{player_id}.png"
  end
end
