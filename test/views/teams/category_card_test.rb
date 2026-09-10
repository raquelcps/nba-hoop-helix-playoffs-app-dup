require "test_helper"

class CategoryCardPartialTest < ActionView::TestCase
  include PlayersHelper

  setup do
    players = [
      {
        player_id: 2,
        player_name: "Second Player",
        pts: 100
      },
      {
        player_id: 1,
        player_name: "Leading Player",
        pts: 200
      }
    ]

    render partial: "teams/category_card",
           locals: {
             title: "Points",
             stat: :pts,
             team_total: 500,
             info: nil,
             players: players
           }
  end

  test "renders the category heading and formatted team total" do
    heading = css_select(".category-card-title").first
    team_total = css_select(".team-total").first

    assert_not_nil heading
    assert_not_nil team_total

    assert_equal "Points", heading.text.strip
    assert_equal "Team: 500", team_total.text.strip
  end

  test "renders player contribution rows in rank order" do
    rows = css_select(".category-card-row")

    assert_equal 2, rows.length

    first_row = rows[0]
    second_row = rows[1]

    assert_equal "1", first_row["data-player-id"]
    assert_equal "1", first_row["data-rank"]
    assert_equal "Leading Player",
                 first_row.at_css(".player-name").text.strip
    assert_equal "200",
                 first_row.at_css(".player-value").text.strip
    assert_equal "40.0%",
                 first_row.at_css(".player-percent").text.strip

    assert_equal "2", second_row["data-player-id"]
    assert_equal "2", second_row["data-rank"]
    assert_equal "Second Player",
                 second_row.at_css(".player-name").text.strip
    assert_equal "100",
                 second_row.at_css(".player-value").text.strip
    assert_equal "20.0%",
                 second_row.at_css(".player-percent").text.strip
  end
end
