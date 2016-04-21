module AthleteHelper
  def strava_link(athlete)
    "https://www.strava.com/athletes/#{athlete.strava_athlete_id}"
  end
end
