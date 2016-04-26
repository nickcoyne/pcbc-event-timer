class AddEditedToStageResults < ActiveRecord::Migration
  def change
    add_column :stage_results, :edited_at, :datetime
  end
end
