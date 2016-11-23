require 'json_parser/json_parser'

class HomeController < ApplicationController

  def index
  end

  def parser
    incoming_json = JSON.parse(File.open(Rails.root.join('db', 'csv_little.json')).read)
    value, seeds = JsonParser.new.parse_json(incoming_json, 'Title')
    respond_to do |format|
      format.json {render json: [value, seeds], status: 200 }
    end
  end

  def save_json
    a=2
  end
end
