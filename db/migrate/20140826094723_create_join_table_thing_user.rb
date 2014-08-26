class CreateJoinTableThingUser < ActiveRecord::Migration
  def change
    create_join_table :things, :users do |t|
      # t.index [:thing_id, :user_id]
      # t.index [:user_id, :thing_id]
    end
  end
end
