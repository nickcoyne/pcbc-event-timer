class StageResult < ActiveRecord::Base
  belongs_to :stage
  belongs_to :athlete

  delegate :event, to: :stage
end
