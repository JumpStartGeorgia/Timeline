class RootController < ApplicationController
	require 'json'
  require 'json_cache'

	CACHE_KEY = "[locale]/[data]"

  def index
    
    # if the category params does not exist or is not valid, reset it
    if (params[:category].blank? && params[:tag].blank?) || @categories.map{|x| x.permalink}.index(params[:category]).nil?
      # default to latest year
      params[:category] = @categories[@categories.length-1].permalink
    end

    if params[:tag].present? && @tags.map{|x| x.permalink}.index(params[:tag]).nil?
      params[:tag] = nil
    end

    @events = get_event_json
    gon.json_data = @events
    gon.show_timeline = gon.json_data.present? ? true : false
    @no_timeline_data = !gon.show_timeline
    gon.hidden_form = true
    gon.form_submission_path = form_submission_path

    render :layout => 'timeline'
    
  end

  def form_submission
    msg = {'status' => 'error'}
    if request.post?
		  @message = Message.new(params[:message])
		  if @message.valid?
				ContactMailer.new_message(@message).deliver
        msg = {'status' => 'success'}
		  end
	  end
    respond_to do |format|
      format.html { redirect root_path}
      format.json { render json: msg.to_json }
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
          h["timeline"]["asset"]["is_img"] = title.is_local_image
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
            x["asset"]["is_img"] = record.is_local_image
          end
        end
      end
      h.to_json
    }

    return JSON.parse(hash)
  end


end
