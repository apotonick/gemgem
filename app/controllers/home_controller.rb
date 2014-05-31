class HomeController < ApplicationController
  def index
    @ratings = [Rating::Twin.find(5), Rating::Twin.find(4)] # TODO: Rating.finders.latest
  end
end
