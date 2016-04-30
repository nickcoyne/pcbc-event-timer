module Stages
  # A Service to import results for a stage
  #
  # stage - the <tt>Stage</tt> for which results should be imported
  # date_range - 'this_year', 'this_month', 'this_week', 'today'
  #
  # Returns true on success
  class ImportResults
    include Service

    attr_reader :stage, :date_range, :event

    def initialize(stage:, date_range: 'today')
      @stage      = stage
      @date_range = date_range
    end

    def call
      results['entries'].each do |result|
        update_stage_result(result)
      end
      true
    end

    private

    def client
      Strava::Api::V3::Client.new(
        access_token: ENV['STRAVA_ACCESS_TOKEN']
      )
    end

    def results
      client.segment_leaderboards(
        stage.strava_segment_id,
        date_range: date_range,
        per_page: page_size
      )
    end

    def update_stage_result(result)
      return unless on_event_date?(result['start_date'])

      athlete = update_athlete(result)
      stage_result = get_stage_result(result['effort_id'])

      stage_result.athlete = athlete
      stage_result.stage = stage
      stage_result.start_time = Time.zone.parse(result['start_date'])
      stage_result.elapsed_time = result['elapsed_time']
      stage_result.distance = result['distance']
      stage_result.save if stage_result.changed?
    end

    def update_athlete(result)
      athlete = get_athlete(result['athlete_id'])
      athlete.name = result['athlete_name']
      athlete.gender = result['athlete_gender']
      athlete.profile_image_url = result['athlete_profile']
      athlete.save if athlete.changed?
      athlete
    end

    def get_athlete(id)
      Athlete.find_or_create_by(strava_athlete_id: id)
    end

    def get_stage_result(effort_id)
      StageResult.find_or_create_by(strava_effort_id: effort_id)
    end

    def on_event_date?(result_date)
      event.date == Time.zone.parse(result_date).to_date
    end

    def event
      @event || stage.event
    end

    def page_size
      200
    end
  end
end
