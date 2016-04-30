class AthletesController < ApplicationController
  before_action :set_athlete, only: [:show, :edit, :update, :destroy]

  # GET /athletes
  def index
    render :index, locals: { athletes: collection, event: event }
  end

  # GET /athletes/1
  def show
    render :show, locals: { athlete: @athlete, stage_results: stage_results }
  end

  # GET /athletes/new
  def new
    @athlete = Athlete.new
  end

  # GET /athletes/1/edit
  def edit
  end

  # POST /athletes
  def create
    @athlete = Athlete.new(athlete_params)

    if @athlete.save
      redirect_to @athlete, notice: 'Athlete was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /athletes/1
  def update
    if @athlete.update(athlete_params)
      redirect_to @athlete, notice: 'Athlete was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /athletes/1
  def destroy
    @athlete.destroy
    redirect_to athletes_url, notice: 'Athlete was successfully destroyed.'
  end

  private

  def set_athlete
    @athlete = Athlete.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def athlete_params
    params.require(:athlete)
          .permit(:name, :gender, :strava_athlete_id, :profile_image_url)
  end

  def collection
    athletes = Athlete.order(order).all
    if event
      athletes = athletes.where(
        id: event.stages.map(&:stage_results).flatten.map(&:athlete_id).uniq
      )
    end
    athletes = athletes.shuffle if params[:random]
    athletes
  end

  def order
    params[:order] || 'name ASC'
  end

  def event
    @event ||= Event.find(params[:event_id]) if params[:event_id]
  end

  def stage_results
    results = @athlete.stage_results
    results = results.joins(:event).where(event: { id: event.id }) if event
    results
  end
end
