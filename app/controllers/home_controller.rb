class HomeController < ApplicationController
  def index
    @ratings = Rating::Twin.finders.all
  end
end
