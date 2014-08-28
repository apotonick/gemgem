class UsersController < ApplicationController
  def search
    render json: [{"label"=>"mylabel","value"=>"myvalue"}]
  end
end
