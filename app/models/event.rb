class Event < ActiveRecord::Base
	translates :headline, :story, :media, :credit, :caption

	has_many :event_translations, :dependent => :destroy
  accepts_nested_attributes_for :event_translations
  attr_accessible :event_translations_attributes, :event_type, :start_date, :end_date, :tag

  validates :start_date, :presence => true
  before_save :add_type

  # type should always be default
  def add_type
    self.event_type = "default" if self.event_type.blank?
  end


end
