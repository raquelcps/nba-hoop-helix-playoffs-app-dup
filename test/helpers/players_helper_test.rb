require "test_helper"

class PlayersHelperTest < ActionView::TestCase
  test "player_contribution calculates percentage for a standard statistical category" do
    result = player_contribution(20, 100)

    assert_equal 20.0, result
  end

  test "player_contribution applies the minutes multiplier" do
    result = player_contribution(240, 240, multiplier: 5)

    assert_equal 20.0, result
  end

  test "player_contribution returns zero when player value is zero" do
    result = player_contribution(0, 100)

    assert_equal 0.0, result
  end

  test "player_contribution returns zero when team total is zero" do
    result = player_contribution(20, 0)

    assert_equal 0, result
  end

  test "player_contribution returns zero when team total is missing" do
    result = player_contribution(20, nil)

    assert_equal 0, result
  end

  test "percentage formatting works correctly for whole numbers" do
    result = format_contribution_percentage(20.0, precision: 0)

    assert_equal "20", result
  end

  test "percentage formatting works correctly for decimal numbers" do
    result = format_contribution_percentage(20.5678, precision: 1)

    assert_equal "20.6", result
  end

end  
