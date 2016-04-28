module Events
  # A Service to import results for a stage
  #
  # event - the <tt>Event</tt> we're looking at
  # athlete - the <tt>Athlete</tt> for whom we want performance
  # excluded_stages - the id's of any stages to exclude from the calculation
  #
  # Returns a multiplier to be used against winner time
  class PerformanceVsWinner
    include Service

    attr_reader :event, :athlete, :excluded_stage_ids

    def initialize(event:, athlete:, excluded_stage_ids: [])
      @event              = event
      @athlete            = athlete
      @excluded_stage_ids = excluded_stage_ids
    end

    def call
      leader_time = 0.0
      athlete_time = 0.0
      stages_for_calculation.each do |stage|
        lr = leading_result(stage)
        ar = athlete_result(stage, athlete)
        if lr > 0 && ar > 0
          leader_time += lr
          athlete_time += ar
        end
      end

      return nil if leader_time == 0 || athlete_time == 0

      athlete_time / leader_time
    end

    def leading_result(stage)
      stage_results = stage.stage_results
      return 0 unless stage_results.present?

      stage.stage_results.min_by(&:elapsed_time).elapsed_time
    end

    private

    def stages_for_calculation
      event.stages - excluded_stages
    end

    def excluded_stages
      excluded_stage_ids.each_with_object([]) { |id, a| a << Stage.find(id) }
    end

    def athlete_result(stage, athlete)
      stage_results = stage.stage_results.where(athlete_id: athlete.id)
      return 0 unless stage_results.present?

      stage_results.min_by(&:elapsed_time).elapsed_time
    end
  end
end
