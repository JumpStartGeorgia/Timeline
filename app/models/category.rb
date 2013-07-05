class Category < ActiveRecord::Base
	translates :name, :permalink

  has_and_belongs_to_many :events
  has_and_belongs_to_many :event_tags, :class_name => 'Event', :join_table => 'events_tags'
	has_many :category_translations, :dependent => :destroy
  accepts_nested_attributes_for :category_translations
  attr_accessible :type_id, :category_translations_attributes
  attr_accessor :type_id_original

  validates :type_id, :presence => true

  after_find :set_original_values
  after_save :check_type_change

  TYPES = {:category => 1, :tag => 2}


  def set_original_values
    self.type_id_original = self.has_attribute?(:type_id) && self.type_id.present? ? self.type_id : nil
  end

  def self.by_type(type_id)
    with_translations(I18n.locale).where(:type_id => type_id).order("category_translations.name asc")
  end

  def self.with_events
    joins('inner join categories_events as ce on categories.id = ce.category_id')
  end

  def type_name
    index = TYPES.values.index(self.type_id)
    if index
      I18n.t("categories.#{TYPES.keys[index]}")
    end
  end

  def self.collection
    x = []

    TYPES.keys.each do |key|
      x << [I18n.t("categories.#{key}"), TYPES[key]]
    end

    return x
  end

  # if the type changed, have to move all associations with events from old type to new type
  def check_type_change
    if self.type_id_original.present? && self.type_id_original != self.type_id
      # move event associations to new type
      events = nil
      if self.type_id_original == 1
        events = self.events
      elsif self.type_id_original == 2
        events = self.event_tags
      end

      if events.present?
        # events exist, move them
        if self.type_id_original == 1
          events.each do |e|
            self.event_tags << e
          end   
          self.events.clear
        elsif self.type_id_original == 2
          events.each do |e|
            self.events << e
          end   
          self.event_tags.clear
        end
        self.save
      end
    end
  end
end

