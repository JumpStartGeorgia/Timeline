class RootController < ApplicationController
	require 'json'
  require 'json_cache'

	CACHE_KEY = "[locale]/[data]"

  def index
    
    gon.json_data = get_event_json
    gon.show_timeline = true

  end



private

  # format:
  # each record has the following format: { type, headline, text, startDate, endDate, asset {media, credit, caption, thumbnail} }
  # {timeline: { title_record, date: [ record, record, ... ] } }
  def get_event_json
    hash = nil
		key = CACHE_KEY.gsub("[locale]", I18n.locale.to_s)
		  .gsub("[data]", 'all')
Rails.logger.debug "333333333333333 - key = #{key}"
		hash = JsonCache.fetch(key) {
Rails.logger.debug "333333333333333 - building data for cache"
      h = Hash.new
      data = Event.sorted

      if data.present?
        h["timeline"] = Hash.new
        h["timeline"]["date"] = []

        # get the title record
        title = data.select{|x| x.event_type == "title"}
        if title.present?
          title = title.first            
          h["timeline"]["type"] = "default"
          h["timeline"]["headline"] = title.headline
          h["timeline"]["text"] = view_context.simple_format title.story
          h["timeline"]["startDate"] = title.start_datetime_timeline
          h["timeline"]["endDate"] = title.end_datetime_timeline
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
              x["text"] = view_context.simple_format record.story
              x["startDate"] = record.start_datetime_timeline
              x["endDate"] = record.end_datetime_timeline
              x["asset"] = Hash.new
              x["asset"]["media"] = record.media
              x["asset"]["credit"] = record.media
              x["asset"]["caption"] = record.media
            end
          end
        end
      end
      h.to_json
    }


    return JSON.parse(hash)
  end


end
