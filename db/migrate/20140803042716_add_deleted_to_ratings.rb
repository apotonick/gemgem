class AddDeletedToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :deleted, :integer
  end
end
