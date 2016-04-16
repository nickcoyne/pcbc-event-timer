class Stage < ActiveRecord::Base
  include RankedModel
  ranks :item_order

  belongs_to :event
  has_many :stage_results

  validates :name, presence: true

  before_save :import_from_strava

  private

  def import_from_strava
    # TODO: Move this to background worker
    client = Strava::Api::V3::Client.new(
      access_token: ENV['STRAVA_ACCESS_TOKEN']
    )
    segment = client.retrieve_a_segment(strava_segment_id)
    self.distance = segment['distance']
  end
end
