class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.text :comment
      t.integer :weight, 'integer unsigned'
    end
  end
end
