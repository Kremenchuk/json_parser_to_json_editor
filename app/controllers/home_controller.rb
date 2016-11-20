class HomeController < ApplicationController

  def index
  end

  def parser
    value, seeds = JsonParser.parse_json
    respond_to do |format|
      format.json {render json: [value, seeds], status: 200 }
    end
  end
end
