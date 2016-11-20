class HomeController < ApplicationController

  def index
  end

  def parser
    incoming_json = JSON.parse(File.open(Rails.root.join('db', 'cml2.json')).read)
    value, seeds = JsonParser.parse_json(incoming_json)
    respond_to do |format|
      format.json {render json: [value, seeds], status: 200 }
    end
  end
end
