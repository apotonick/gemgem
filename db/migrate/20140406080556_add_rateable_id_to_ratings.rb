class AddRateableIdToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :thing_id, :integer

    create_table :things do |t|
      t.text :name
    end
  end
end
