class AddImageMetaDataToThings < ActiveRecord::Migration
  def change
    add_column :things, :image_meta_data, :text
  end
end
