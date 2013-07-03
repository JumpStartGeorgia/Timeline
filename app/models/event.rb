class Event < ActiveRecord::Base
  include Rails.application.routes.url_helpers
	translates :headline, :story, :media, :credit, :caption

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :tags, :class_name => 'Category', :join_table => 'events_tags'
	has_many :event_translations, :dependent => :destroy
  accepts_nested_attributes_for :event_translations
  attr_accessible :event_translations_attributes, :event_type, :start_date, :start_time, :end_date, :end_time, :tag, :category_ids, :tag_ids

  validates :start_date, :presence => true
  validate :required_category
  before_save :add_type

  before_destroy :remove_media_img, :prepend => true

  def remove_media_img
    self.event_translations.each do |trans|
      trans.media_img = nil
      trans.save
    end
  end 

  def self.sorted
    with_translations(I18n.locale).order("events.start_date, events.start_time, event_translations.headline")
  end

  def self.with_filters
    includes(:categories => :category_translations, :tags => :category_translations)
  end

  def self.apply_filter(category=nil, tag=nil)
    if category.present?
      joins(:categories => :category_translations).where(['category_translations.permalink = ? and category_translations.locale = ?', category, I18n.locale])
    elsif tag.present?
      joins(:tags => :category_translations).where(['category_translations.permalink = ? and category_translations.locale = ?', tag, I18n.locale])
    else
      all
    end
  end

  # type should always be default
  def add_type
    self.event_type = "default" if self.event_type.blank?
  end

  # make sure category is provided in order to save
  def required_category
    errors.add(:base, t('activerecord.errors.messages.required_category')) if categories.blank?
  end

  def start_time
    read_attribute("start_time").in_time_zone('Tbilisi') if read_attribute("start_time").present?
  end

  def end_time
    read_attribute("end_time").in_time_zone('Tbilisi') if read_attribute("end_time").present?
  end

  def start_datetime_timeline
    if self.start_date.present? && self.start_time.present?
      "#{I18n.l self.start_date, :format => :timeline} #{I18n.l self.start_time, :format => :time_only}"
    elsif self.start_date.present?
      I18n.l self.start_date, :format => :timeline
    else
      nil
    end
  end

  def start_datetime_formatted
    if self.start_date.present? && self.start_time.present?
      "#{I18n.l self.start_date} #{I18n.l self.start_time, :format => :time_only}"
    elsif self.start_date.present?
      I18n.l self.start_date
    else
      nil
    end
  end

  def end_datetime_timeline
    if self.end_date.present? && self.end_time.present?
      "#{I18n.l self.end_date, :format => :timeline} #{I18n.l self.end_time, :format => :time_only}"
    elsif self.end_date.present?
      I18n.l self.end_date, :format => :timeline
    else
      nil
    end
  end

  def end_datetime_formatted
    if self.end_date.present? && self.end_time.present?
      "#{I18n.l self.end_date} #{I18n.l self.end_time, :format => :time_only}"
    elsif self.end_date.present?
      I18n.l self.end_date
    else
      nil
    end
  end


	##############################
	## shortcut methods to get to
	## image file in image_file object
	##############################
	def media_url
		self.event_translations.select{|x| x.locale == I18n.locale.to_s}.first.media_url
	end

######################
  ## load from json
  ## - expect each item to have key names that match attr names
  ######################
  def self.load_from_json(json)
    if json.present?
      Event.transaction do
        json.each_with_index do |record, index|
          puts index
          # make sure times are in proper timezone
          e = Event.new(:event_type => record["event_type"],
                        :start_date => record["start_date"], 
                        :start_time => record["start_time"].present? ? Time.strptime(record["start_time"], '%H:%M') : nil, 
                        :end_date => record["end_date"], 
                        :end_time => record["end_time"].present? ? Time.strptime(record["end_time"], '%H:%M') : nil)

          # if category value exists, add it
          if record["category"].present?
            # see if already in system
            cat = Category.includes(:category_translations).where(["category_translations.name = ? and category_translations.locale = ?", record["category"], I18n.locale])
            cat_record = nil
            if cat.present?
              # already exists, save id
              cat_record = cat.first
            else
              # not exist, create category
              cat = Category.create(:type_id => Category::TYPES[:category])
              cat.category_translations.create(:locale => 'ka', :name => record["category"])
              cat.category_translations.create(:locale => 'en', :name => record["category"])
              cat_record = cat
            end

            # assign to category
            if cat_record.present?
              e.categories << cat_record
            end
          end

          if e.save
            e.event_translations.create(:locale => 'en', :headline => record["headline"], :story => record["story"], 
                  :media => record["media"], :credit => record["credit"], :caption => record["caption"])          
            e.event_translations.create(:locale => 'ka', :headline => record["headline"], :story => record["story"], 
                  :media => record["media"], :credit => record["credit"], :caption => record["caption"])          
          else
            puts "****************************"
            puts e.errors.full_messages
          end
        end
      end
    end
  end

  ######################
  ## load from json with mutliple languages
  ## - expect each item to have key names that match attr names
  ######################
  def self.load_from_json_multi_lang(ka_json, en_json)
    if ka_json.present? && en_json.present?
      Event.transaction do
        ka_json.each_with_index do |record, index|
          puts index

          # get en record
          en_record = en_json.select{|x| x["id"] == record["id"]}.first

          # make sure times are in proper timezone
          e = Event.new(:event_type => record["event_type"],
                        :start_date => record["start_date"], 
                        :start_time => record["start_time"].present? ? Time.strptime(record["start_time"], '%H:%M') : nil, 
                        :end_date => record["end_date"], 
                        :end_time => record["end_time"].present? ? Time.strptime(record["end_time"], '%H:%M') : nil)

          # if category value exists, add it
          if record["category"].present?
            # see if already in system
            cat = Category.includes(:category_translations).where(["category_translations.name = ? and category_translations.locale = ?", record["category"], 'ka'])
            cat_record = nil
            if cat.present?
              # already exists, save id
              cat_record = cat.first
            else
              # not exist, create category
              cat = Category.create(:type_id => Category::TYPES[:category])
              cat.category_translations.create(:locale => 'ka', :name => record["category"])
              if en_record["category"].present?
                cat.category_translations.create(:locale => 'en', :name => en_record["category"])
              else
puts "********************************"
puts "----------- - could not find en category match for #{record["category"]}"
                cat.category_translations.create(:locale => 'en', :name => record["category"])
              end
              cat_record = cat
            end

            # assign to category
            if cat_record.present?
              e.categories << cat_record
            end
          end

          if e.save
            e.event_translations.create(:locale => 'ka', :headline => record["headline"], :story => record["story"], 
                  :media => record["media"], :credit => record["credit"], :caption => record["caption"])          

            if en_record.present?
              e.event_translations.create(:locale => 'en', :headline => en_record["headline"], :story => en_record["story"], 
                    :media => en_record["media"], :credit => en_record["credit"], :caption => en_record["caption"])          
            else
puts "********************************"
puts "----------- - could not find en match for #{record["id"]}"
              e.event_translations.create(:locale => 'en', :headline => record["headline"], :story => record["story"], 
                    :media => record["media"], :credit => record["credit"], :caption => record["caption"])          
            end
          else
            puts "****************************"
            puts e.errors.full_messages
          end
        end
      end
    end
  end

  # generate timeline json format for this event
  # - timeline requires the title and at least one event
  #   so copying this event into both places
  def to_timeline_json
    h = Hash.new
    h["timeline"] = Hash.new
    h["timeline"]["date"] = []

    # create empty title event
    h["timeline"]["type"] = "default"
    h["timeline"]["headline"] = nil

    # add event
    x = Hash.new
    h["timeline"]["date"] << x
    x["type"] = "default"
    x["headline"] = self.headline
    x["text"] = self.story
    x["categories"] = self.categories.present? ? self.categories.map{|x| {:name => x.name, :permalink => x.permalink}} : nil
    x["tags"] = self.tags.present? ? self.tags.map{|x| {:name => x.name, :permalink => x.permalink}} : nil
    x["startDate"] = self.start_datetime_timeline
    x["endDate"] = self.end_datetime_timeline
    x["asset"] = Hash.new
    x["asset"]["media"] = self.media_url
    x["asset"]["credit"] = self.credit
    x["asset"]["caption"] = self.caption

    return h
  end


end
