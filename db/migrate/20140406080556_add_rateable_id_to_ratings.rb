class AddRateableIdToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :rateable_id, :integer

    create_table :rateables do |t|
      t.text :name
    end
  end
end
