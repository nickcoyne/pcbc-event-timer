class AddStravaEffortIdToStageResults < ActiveRecord::Migration
  def change
    add_column :stage_results, :strava_effort_id, :integer, limit: 8
  end
end
