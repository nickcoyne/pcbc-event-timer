class EventsController < ApplicationController
  before_action :set_event,
                only: [:show, :edit, :update, :destroy, :import_results]

  # GET /events
  def index
    render :index, locals: { events: Event.all }
  end

  # GET /events/1
  def show
    results = {}
    @event.stages.each do |stage|
      stage_results =
        stage.stage_results
             .select('athlete_id, MIN(elapsed_time) AS elapsed_time')
             .joins(:athlete)
             .group(:athlete_id)

      stage_results.each do |stage_result|
        results[stage_result.athlete] ||= {}
        results[stage_result.athlete][:total] ||= 0
        results[stage_result.athlete][:completed_count] ||= 0

        results[stage_result.athlete][stage.id.to_s] = stage_result.elapsed_time
        results[stage_result.athlete][:total] += stage_result.elapsed_time
        results[stage_result.athlete][:completed_count] += 1
      end
    end

    results_for_render =
      results.sort_by do |_key, value|
        [(@event.stages.size - value[:completed_count]), value[:total]]
      end

    render :show,
           locals: {
             event: @event,
             results: results_for_render
           }
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  def import_results
    @event.stages.each do |stage|
      ::Stages::ImportResults.call(stage: stage)
    end

    redirect_to event_path(@event)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def event_params
    params.require(:event).permit(:name, :date)
  end
end
