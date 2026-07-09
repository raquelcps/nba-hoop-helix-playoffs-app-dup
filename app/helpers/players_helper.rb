module PlayersHelper
  include ActionView::Helpers::NumberHelper

  # TODO: think about team minutes and multiplier. Shoudl team minutes be 48 * 5? Or 48? 
  # If playerA plays 48 minutes and team plays 240 minutes (48*5), then playerA played 20% of team minutes.
  # If playerA plays 48 minutes and team plays 48 minutes, then playerA played 100% of team minutes.
  # Considering that i am getting total stat counts for player and team and showing percentages as a way to show the relationship between player and team totals, I think it makes sense to use 48 * 5 as team minutes so that an individual player can not possibly contribute more than 20% of mins since mins will always be shared by 5 players on the court at a time.
  # 
  def player_contribution(player_stat, team_stat, multiplier: 1)
    multiplier = multiplier.nil? ? 1.0 : multiplier.to_f
    denominator = team_stat.to_f * multiplier

    return 0 if player_stat.nil? || team_stat.nil? || denominator.zero?

    ((player_stat.to_f / denominator) * 100)
  end

  def format_contribution_percentage(value, precision: 1)
    number_with_precision(value, precision: precision)
  end

  # Compute contributions for multiple stats (not mins since that needs special handling with multiplier; not passes since i haven't collected that data yet)
  def player_contribution_stats(player_data, team_totals, stats:, multiplier: nil)
    puts "######Debugging message in player_contribution_stats: player_data: #{player_data}, team_totals: #{team_totals}, stats: #{stats}, multiplier: #{multiplier}"
    stats.each_with_object({}) do |stat, hash|
      stat_multiplier = (stat == :min ? 5 : 1) if multiplier.nil?

      hash[stat] = 
        player_contribution(
          player_data[stat],
          team_totals[stat],
          multiplier: stat_multiplier)

      puts "######Debugging message in player_contribution_stats: stat: #{stat}, player_contribution: #{hash[stat]}"
    end
  end

  def player_rankings(players, stats:)
    rankings = {}

    stats.each do |stat|

      sorted_players =
        players.sort_by { |player| player[stat] || 0 }
              .reverse

      rankings[stat] =
        sorted_players.each_with_index.map do |player, index|

          above = index.zero? ? nil : sorted_players[index - 1][stat]
          below =
            index == sorted_players.length - 1 ?
              nil :
              sorted_players[index + 1][stat]

          [
            player[:player_id],
            {
              rank: index + 1,
              value: player[stat],

              above: above.nil? ? nil : {
                rank: index,
                value: above
              },

              below: below.nil? ? nil : {
                rank: index + 2,
                value: below
              }
            }
          ]

        end.to_h

    end

    rankings
  end
end
