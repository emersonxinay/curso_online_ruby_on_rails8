class HomeController < ApplicationController
  def index
    @featured_courses = Course.published.recent.limit(6)
    @latest_courses = Course.published.recent.limit(3)
  end
end
