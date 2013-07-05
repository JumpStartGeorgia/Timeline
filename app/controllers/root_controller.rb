class RootController < ApplicationController
	require 'json'
  require 'json_cache'

	CACHE_KEY = "[locale]/[data]"

  def index
    
    gon.json_data = get_event_json
    gon.show_timeline = gon.json_data.present? ? true : false
    @no_timeline_data = !gon.show_timeline

  end



private

  # format:
  # each record has the following format: { type, headline, text, startDate, endDate, asset {media, credit, caption, thumbnail} }
  # {timeline: { title_record, date: [ record, record, ... ] } }
  def get_event_json
    hash = nil
    data_type = "all"
    data_type << "_category_#{params[:category]}" if params[:category].present?
    data_type << "_tag_#{params[:tag]}" if params[:tag].present?
		key = CACHE_KEY.gsub("[locale]", I18n.locale.to_s)
		  .gsub("[data]", data_type)

		hash = JsonCache.fetch(key) {
      h = Hash.new
      data = Event.sorted.apply_filter(params[:category], params[:tag])

      if data.present?
        h["timeline"] = Hash.new
        h["timeline"]["date"] = []

        # get the title record
        if data.class == ActiveRecord::Relation
          title = nil
          the_rest = data
        else
          title = data.select{|x| x.event_type == "title"}
          the_rest = data.select{|x| x.event_type != "title"}
        end
        if title.present?
          title = title.first            
          h["timeline"]["type"] = "default"
          h["timeline"]["headline"] = title.headline
          h["timeline"]["text"] = build_story(title.story, title.categories, title.tags)
          h["timeline"]["startDate"] = title.start_datetime_timeline
          h["timeline"]["endDate"] = title.end_datetime_timeline
          h["timeline"]["asset"] = Hash.new
          h["timeline"]["asset"]["media"] = title.media_url
          h["timeline"]["asset"]["credit"] = title.credit
          h["timeline"]["asset"]["caption"] = title.caption
        else
          # create empty title event
          h["timeline"]["type"] = "default"
          h["timeline"]["headline"] = nil
        end
        
        # now add all of the rest of the data
        if the_rest.present?
          the_rest.each do |record|
            x = Hash.new
            h["timeline"]["date"] << x
            x["type"] = record.event_type
            x["headline"] = record.headline
            x["text"] = build_story(record.story, record.categories, record.tags)
            x["startDate"] = record.start_datetime_timeline
            x["endDate"] = record.end_datetime_timeline
            x["asset"] = Hash.new
            x["asset"]["media"] = record.media_url
            x["asset"]["credit"] = record.credit
            x["asset"]["caption"] = record.caption
          end
        end
      end
      h.to_json
    }


    return JSON.parse(hash)
  end


end
