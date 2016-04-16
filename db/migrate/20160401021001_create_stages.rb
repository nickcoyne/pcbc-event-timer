class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name
      t.integer :event_id
      t.integer :strava_segment_id
      t.integer :item_order
      t.float :distance

      t.timestamps null: false
    end
  end
end
