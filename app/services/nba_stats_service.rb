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

  TEAM_ABBREVIATIONS = {
    "ATL" => 1610612737,
    "BOS" => 1610612738,
    "BKN" => 1610612751,
    "CHA" => 1610612766,
    "CHI" => 1610612741,
    "CLE" => 1610612739,
    "DAL" => 1610612742,
    "DEN" => 1610612743,
    "DET" => 1610612765,
    "GSW" => 1610612744,
    "HOU" => 1610612745,
    "IND" => 1610612754,
    "LAC" => 1610612746,
    "LAL" => 1610612747,
    "MEM" => 1610612763,
    "MIA" => 1610612748,
    "MIL" => 1610612749,
    "MIN" => 1610612750,
    "NOP" => 1610612740,
    "NYK" => 1610612752,
    "OKC" => 1610612760,
    "ORL" => 1610612753,
    "PHI" => 1610612755,
    "PHX" => 1610612756,
    "POR" => 1610612757,
    "SAC" => 1610612758,
    "SAS" => 1610612759,
    "TOR" => 1610612761,
    "UTA" => 1610612762,
    "WAS" => 1610612764
  }.freeze

  # -------------------
  # Public API methods
  # -------------------

  def self.playoff_teams(season: "2025-26")
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
      puts "Debugging message in playoff_teams: response: #{response}" # Debugging message
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

  def self.team_totals(team_id:, season: "2025-26", poround: 0)
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
      # normalize_result(response).first
      stats = normalize_result(response).first
      return nil unless stats
      
      {
        team_id:      stats["TEAM_ID"],
        team_name:    stats["TEAM_NAME"],
        gp:           stats["GP"],
        w:            stats["W"],
        l:            stats["L"],
        w_pct:        stats["W_PCT"],
        min:          stats["MIN"],
        fgm:          stats["FGM"],
        fga:          stats["FGA"],
        fg_pct:       stats["FG_PCT"],
        fg3m:         stats["FG3M"],
        fg3a:         stats["FG3A"],
        fg3_pct:      stats["FG3_PCT"],
        ftm:          stats["FTM"],
        fta:          stats["FTA"],
        ft_pct:       stats["FT_PCT"],
        oreb:         stats["OREB"],
        dreb:         stats["DREB"],
        reb:          stats["REB"],
        ast:          stats["AST"],
        tov:          stats["TOV"],
        stl:          stats["STL"],
        blk:          stats["BLK"],
        blka:         stats["BLKA"],
        pf:           stats["PF"],
        pfd:          stats["PFD"],
        pts:          stats["PTS"],
        plus_minus:   stats["PLUS_MINUS"]
      }.with_indifferent_access
    end
  end

  def self.team_players(team_id:, season: "2025-26", poround: 0)
    Rails.cache.fetch("nba/team_players/#{team_id}/#{season}/#{poround}", expires_in: 12.hours) do
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

  def self.team_roster(team_id:, season: "2025-26")
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
          exp: row["EXP"],
          height: row["HEIGHT"],
          weight: row["WEIGHT"],
          photo_url: player_photo_url(row["PLAYER_ID"])
        }
      end
    end
  end

  # -------------------
  # Team Game Logs
  # -------------------

  def self.team_game_logs(team_id:, season: "2025-26", poround: 0)
    Rails.cache.fetch(
      "nba/team_game_logs/#{team_id}/#{season}/#{poround}",
      expires_in: 12.hours
    ) do

      response = get_json("teamgamelogs", {
        TeamID: team_id,
        Season: season,
        SeasonType: "Playoffs",
        PORound: poround,
        LeagueID: "00"
      })

      normalize_result(response)
    end
  end

  def self.playoff_opponent(team_id:, season: "2025-26", poround:)
    games =
      team_game_logs(
        team_id: team_id,
        season: season,
        poround: poround
      )

    return nil if games.empty?

    game = games.first
    matchup = game["MATCHUP"]

    return nil if matchup.blank?

    opponent_abbreviation =
      if matchup.include?(" @ ")
        visitor, home = matchup.split(" @ ")
        visitor == game["TEAM_ABBREVIATION"] ? home : visitor
      elsif matchup.include?(" vs. ")
        home, visitor = matchup.split(" vs. ")
        home == game["TEAM_ABBREVIATION"] ? visitor : home
      else
        return nil
      end

    opponent_id = TEAM_ABBREVIATIONS[opponent_abbreviation]

    return nil unless opponent_id

    opponent =
      playoff_teams(season: season)
        .find { |team| team[:team_id] == opponent_id }

    return nil unless opponent

    {
      opponent_team_id: opponent[:team_id],
      opponent_team_name: opponent[:team_name],
      opponent_logo_url: opponent[:logo_url]
    }
  end

  # -------------------
  # Helpers
  # -------------------

  def self.get_json(endpoint, params = {})
    url = "#{BASE_URL}/#{endpoint}"
    response = HTTParty.get(url, query: params, headers: DEFAULT_HEADERS)
    body = response.body.to_s

    if response.code == 200
      puts "Debugging message response code: #{response.code}"
    else
      Rails.logger.error "NBA API error for #{endpoint}: #{response.code} - #{body}"
    end

    if body.strip.empty?
      Rails.logger.error "NBA API returned an empty body for #{endpoint} (params: #{params.inspect})"
      return { "resultSets" => [{ "headers" => [], "rowSet" => [] }] }
    end

    JSON.parse(body)
  rescue JSON::ParserError => e
    Rails.logger.error "NBA API JSON parse error for #{endpoint}: #{e.message}. Body starts with: #{body[0, 200].inspect}"
    { "resultSets" => [{ "headers" => [], "rowSet" => [] }] }
  end

  def self.normalize_result(response)
    result_set = response["resultSets"]&.first
    return [] unless result_set

    headers = result_set["headers"]
    row_set = result_set["rowSet"]
    return [] unless headers && row_set

    row_set.map { |row| headers.zip(row).to_h }
    # Rails.logger.debug "Keys in normalize_result: #{rows.first.keys.inspect}" if rows.any?
  end

  def self.team_logo_url(team_id)
    "https://cdn.nba.com/logos/nba/#{team_id}/primary/L/logo.svg"
  end

  def self.player_photo_url(player_id)
    "https://cdn.nba.com/headshots/nba/latest/260x190/#{player_id}.png"
  end
end
