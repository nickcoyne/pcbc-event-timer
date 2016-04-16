class CreateStageResults < ActiveRecord::Migration
  def change
    create_table :stage_results do |t|
      t.integer :stage_id
      t.integer :athlete_id
      t.datetime :start_time
      t.integer :elapsed_time
      t.float :distance

      t.timestamps null: false
    end
  end
end
