class Athlete < ActiveRecord::Base
  has_many :stage_results
end
