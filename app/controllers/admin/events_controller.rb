class Admin::EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:user])
  end
	cache_sweeper :event_sweeper, :only => [:create, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: EventsDatatable.new(view_context) }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
#    title_event = Event.title_event

    gon.show_timeline = true
    json = @event.to_timeline_json
    # add categories and tags to story
    story = build_story(json["timeline"]["date"][0]["text"], json["timeline"]["date"][0]["categories"], json["timeline"]["date"][0]["tags"])

    # apply simple format to the text
    json["timeline"]["date"][0]["text"] = view_context.simple_format story
    gon.json_data = json

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    @tags = Category.by_type(Category::TYPES[:tag])

    # create the translation object for the locales that were selected
	  # so the form will properly create all of the nested form fields
		I18n.available_locales.each do |locale|
			@event.event_translations.build(:locale => locale.to_s)
		end

    gon.edit_event = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @tags = Category.by_type(Category::TYPES[:tag])

    gon.edit_event = true
		gon.start_date = @event.start_date.strftime('%m/%d/%Y %H:%M') if @event.start_date.present?
		gon.end_date = @event.end_date.strftime('%m/%d/%Y %H:%M') if @event.end_date.present?
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to admin_event_path(@event), notice: t('app.msgs.success_created', :obj => t('activerecord.models.event')) }
        format.json { render json: @event, status: :created, location: @event }
      else
        @tags = Category.by_type(Category::TYPES[:tag])
        gon.edit_event = true
		    gon.start_date = @event.start_date.strftime('%m/%d/%Y %H:%M') if @event.start_date.present?
		    gon.end_date = @event.end_date.strftime('%m/%d/%Y %H:%M') if @event.end_date.present?
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to admin_event_path(@event), notice: t('app.msgs.success_updated', :obj => t('activerecord.models.event')) }
        format.json { head :ok }
      else
        @tags = Category.by_type(Category::TYPES[:tag])
        gon.edit_event = true
		    gon.start_date = @event.start_date.strftime('%m/%d/%Y %H:%M') if @event.start_date.present?
		    gon.end_date = @event.end_date.strftime('%m/%d/%Y %H:%M') if @event.end_date.present?
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to admin_events_url }
      format.json { head :ok }
    end
  end
end
