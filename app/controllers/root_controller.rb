class RootController < ApplicationController

  def index
    events = Event.sorted
    
    gon.json_data = to_json(events)

  end



private

  # format:
  # each record has the following format: { type, headline, text, startDate, endDate, asset {media, credit, caption, thumbnail} }
  # {timeline: { title_record, date: [ record, record, ... ] } }
  def to_json(data)
    h = Hash.new
    h["timeline"] = Hash.new
    h["timeline"]["date"] = []

    # get the title record
    title = data.select{|x| x.event_type == "title"}
    if title.present?
      title = title.first            
      h["timeline"]["type"] = "default"
      h["timeline"]["headline"] = title.headline
      h["timeline"]["text"] = title.story
      h["timeline"]["startDate"] = title.start_datetime
      h["timeline"]["endDate"] = title.end_datetime
      h["timeline"]["asset"] = Hash.new
      h["timeline"]["asset"]["media"] = title.media
      h["timeline"]["asset"]["credit"] = title.media
      h["timeline"]["asset"]["caption"] = title.media
    
      # now add all of the rest of the data
      the_rest = data.select{|x| x.event_type != "title"}
      if the_rest.present?
        the_rest.each do |record|
          x = Hash.new
          h["timeline"]["date"] << x
          x["type"] = record.event_type
          x["headline"] = record.headline
          x["text"] = record.story
          x["startDate"] = record.start_datetime
          x["endDate"] = record.end_datetime
          x["asset"] = Hash.new
          x["asset"]["media"] = record.media
          x["asset"]["credit"] = record.media
          x["asset"]["caption"] = record.media
        end
      end
    end

    return h
  end


end
