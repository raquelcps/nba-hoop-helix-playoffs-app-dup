module PlayersHelper
  def player_contribution(player_stat, team_stat, multiplier: 1)
    puts "Debugging message in player_contribution:"
    puts "player_stat: #{player_stat}, team_stat: #{team_stat}, multiplier: #{multiplier}"
    return 0 if player_stat.nil? || team_stat.nil? || team_stat.to_f.zero?

    ((player_stat.to_f / (team_stat.to_f * multiplier)) * 100).round(2)
  end
end
