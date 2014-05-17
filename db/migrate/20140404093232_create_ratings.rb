class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.text   :comment
      t.column :weight, 'integer unsigned'
    end
  end
end
