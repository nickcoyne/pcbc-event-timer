class StageResultsController < ApplicationController
  before_action :set_stage_result, only: [:show, :edit, :update, :destroy]

  # GET /stage_results
  def index
    @stage_results = StageResult.all
  end

  # GET /stage_results/1
  def show
  end

  # GET /stage_results/new
  def new
    @stage_result = StageResult.new
  end

  # GET /stage_results/1/edit
  def edit
    render :edit, locals: { stage_result: @stage_result }
  end

  # POST /stage_results
  def create
    @stage_result = StageResult.new(stage_result_params)

    if @stage_result.save
      redirect_to @stage_result,
                  notice: 'Stage result was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /stage_results/1
  def update
    if @stage_result.update(stage_result_params)
      @stage_result.update_column(:edited_at, Time.current)
      redirect_to event_stage_path(
        @stage_result.stage.event,
        @stage_result.stage,
        athlete_id: @stage_result.athlete_id
      ),
      notice: 'Stage result was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /stage_results/1
  def destroy
    @stage_result.destroy
    redirect_to event_stage_path(
      @stage_result.stage.event,
      @stage_result.stage,
      athlete_id: @stage_result.athlete_id
    ),
    notice: 'Stage result was successfully destroyed.'
  end

  private

  def set_stage_result
    @stage_result = StageResult.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def stage_result_params
    params.require(:stage_result)
          .permit(:stage_id, :athlete_id, :start_time, :elapsed_time, :distance)
  end
end
