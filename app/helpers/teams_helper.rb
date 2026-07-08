module TeamsHelper
  def player_last_name(player)
    player[:player_name].split.last
  end
end
