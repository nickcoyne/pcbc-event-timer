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
      %w[M F].each do |gender|
        results(gender)['entries'].each do |result|
          update_stage_result(result, gender)
        end
      end
      true
    end

    private

    def client
      Strava::Api::V3::Client.new(
        access_token: ENV['STRAVA_ACCESS_TOKEN']
      )
    end

    def results(gender)
      client.segment_leaderboards(
        stage.strava_segment_id,
        gender: gender,
        date_range: date_range,
        per_page: page_size
      )
    end

    def update_stage_result(result, gender)
      return unless on_event_date?(result['start_date'])

      athlete = update_athlete(result, gender)
      stage_result =
        get_stage_result(
          athlete.id,
          stage.id,
          Time.zone.parse(result['start_date'])
        )

      stage_result.athlete = athlete
      stage_result.stage = stage
      stage_result.start_time = Time.zone.parse(result['start_date'])
      stage_result.elapsed_time = result['elapsed_time']
      # stage_result.distance = result['distance']
      stage_result.save if stage_result.changed?
    end

    def update_athlete(result, gender)
      athlete = get_athlete(result['athlete_name'])
      # athlete.name = result['athlete_name']
      athlete.gender = gender
      # athlete.profile_image_url = result['athlete_profile']
      athlete.save if athlete.changed?
      athlete
    end

    def get_athlete(name)
      Athlete.find_or_create_by(name: name)
    end

    def get_stage_result(athlete_id, stage_id, start_time)
      StageResult.find_or_create_by(
        athlete_id: athlete_id,
        stage_id: stage_id,
        start_time: start_time
      )
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
