class RootController < ApplicationController
	require 'json'
  require 'json_cache'

	CACHE_KEY = "[locale]/[data]"

  def index
    
    gon.highlight_first_form_field = false
    gon.json_data = get_event_json
    gon.show_timeline = gon.json_data.present? ? true : false
    @no_timeline_data = !gon.show_timeline
    
    # get the about text
    if File.exists?(@about_path)
      about_text = JSON.parse(File.read(@about_path))
      @about = about_text[I18n.locale.to_s]
    end

    respond_to do |format|
      format.html { render :layout => 'timeline'}
    end
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

        title_input = '<input type="hidden" class="title_here" />'.html_safe;

        if title.present?
          title = title.first            
          h["timeline"]["type"] = "default"
          h["timeline"]["id"] = record.id.to_s
          h["timeline"]["headline"] = title.headline + title_input # to find this from javascript
          h["timeline"]["text"] = build_story(title.story, title.categories, title.tags, record.id)
          h["timeline"]["startDate"] = title.start_datetime_timeline
          h["timeline"]["endDate"] = title.end_datetime_timeline
          h["timeline"]["asset"] = Hash.new
          if title.media_url.index('/system/') == 0
            h["timeline"]["asset"]["media"] = "#{request.protocol}#{request.host_with_port}#{title.media_url}"
          else 
            h["timeline"]["asset"]["media"] = title.media_url
          end

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
            x["id"] = record.id.to_s
            x["type"] = record.event_type
            x["headline"] = record.headline + title_input # to find this from javascript
            x["text"] = build_story(record.story, record.categories, record.tags, record.id)
            x["startDate"] = record.start_datetime_timeline
            x["endDate"] = record.end_datetime_timeline
            x["asset"] = Hash.new
            if record.media_url.index('/system/') == 0
              x["asset"]["media"] = "#{request.protocol}#{request.host_with_port}#{record.media_url}"
            else 
              x["asset"]["media"] = record.media_url
            end
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
