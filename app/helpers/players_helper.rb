module PlayersHelper
  # TODO: think about team minutes and multiplier. Shoudl team minutes be 48 * 5? Or 48? 
  # If playerA plays 48 minutes and team plays 240 minutes (48*5), then playerA played 20% of team minutes.
  # If playerA plays 48 minutes and team plays 48 minutes, then playerA played 100% of team minutes.
  # Considering that i am getting total stat counts for player and team and showing percentages as a way to show the relationship between player and team totals, I think it makes sense to use 48 * 5 as team minutes so that an individual player can not possibly contribute more than 20% of mins since mins will always be shared by 5 players on the court at a time.
  # 
  def player_contribution(player_stat, team_stat, multiplier: 1)
    multiplier = multiplier.nil? ? 1.0 : multiplier.to_f
    denominator = team_stat.to_f * multiplier

    puts "****Debugging message in player_contribution:"
    puts "player_stat: #{player_stat}, team_stat: #{team_stat}, multiplier: #{multiplier}"
    puts "player_stat.to_f: #{player_stat.to_f}"
    puts "team_stat.to_f * multiplier: #{denominator}"
    puts "(player_stat.to_f / (team_stat.to_f * multiplier)) * 100: #{(player_stat.to_f / denominator) * 100}"
    return 0 if player_stat.nil? || team_stat.nil? || denominator.zero?

    ((player_stat.to_f / denominator) * 100).round(2)
  end

  # Compute contributions for multiple stats (not mins since that needs special handling with multiplier; not passes since i haven't collected that data yet)
  def player_contribution_stats(player_data, team_totals, stats:, multiplier: nil)
    # puts "######Debugging message in player_contribution_stats: player_data: #{player_data}, team_totals: #{team_totals}, stats: #{stats}, multiplier: #{multiplier}"
    stats.each_with_object({}) do |stat, hash|
      puts "Processing stat: #{stat}"
      puts "player_data: #{player_data}"
      puts "team_totals: #{team_totals}"
      puts "player_data[stat]: #{player_data[stat]}, team_totals[stat]: #{team_totals[stat]}, multiplier: #{multiplier}"
      hash[stat] = player_contribution(player_data[stat], team_totals[stat], multiplier:)
    end
  end
end
