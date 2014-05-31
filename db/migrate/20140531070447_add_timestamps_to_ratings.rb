class AddTimestampsToRatings < ActiveRecord::Migration
  def change
    change_table :ratings do |t|
      t.timestamps
    end
  end
end
