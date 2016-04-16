class CreateAthletes < ActiveRecord::Migration
  def change
    create_table :athletes do |t|
      t.string :name
      t.string :gender
      t.integer :strava_athlete_id
      t.string :profile_image_url

      t.timestamps null: false
    end
  end
end
