class AddNameAndPlayerIdToPlayers < ActiveRecord::Migration[7.1]
  def change
  	change_table :players do |t|
      t.string :name
      t.integer :person_id

    end
  end
end
