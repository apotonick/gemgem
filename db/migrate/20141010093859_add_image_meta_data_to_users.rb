class AddImageMetaDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_meta_data, :text
  end
end
