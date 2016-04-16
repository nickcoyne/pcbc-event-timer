class StagesController < ApplicationController
  before_action :set_event, except: [:create]
  before_action :set_stage,
                only: [:show, :edit, :update, :destroy, :import_results]

  # GET /stages
  def index
    render :index,
           locals: {
              event: @event,
              stages: @event.stages.order(:item_order)
            }
  end

  # GET /stages/1
  def show
    @stage_results = @stage.stage_results.order(:elapsed_time)
    render :show,
           locals: {
             event: @event,
             stage: @stage,
             stage_results: @stage_results
           }
  end

  # GET /stages/new
  def new
    @stage = @event.stages.new
    render :new, locals: { event: @event, stage: @stage }
  end

  # GET /stages/1/edit
  def edit
    render :edit, locals: { event: @event, stage: @stage }
  end

  # POST /stages
  def create
    @event = Event.find(stage_params[:event_id])
    @stage = @event.stages.new(stage_params)

    if @stage.save
      redirect_to event_stages_path(@event),
                  notice: 'Stage was successfully created.'
    else
      render :new, locals: { event: @event, stage: @stage }
    end
  end

  # PATCH/PUT /stages/1
  def update
    if @stage.update(stage_params)
      redirect_to event_stages_path(@event),
                  notice: 'Stage was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /stages/1
  def destroy
    @stage.destroy
    redirect_to event_stages_path(@event),
                notice: 'Stage was successfully destroyed.'
  end

  def import_results
    ::Stages::ImportResults.call(stage: @stage, date_range: params[:date_range])

    redirect_to event_stage_path(@event, @stage)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_stage
    @stage = @event.stages.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def stage_params
    params.require(:stage)
          .permit(:name, :event_id, :strava_segment_id, :item_order, :distance)
  end
end
