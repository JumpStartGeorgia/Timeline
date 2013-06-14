class EventTranslation < ActiveRecord::Base

	belongs_to :event

  attr_accessible :event_id, :locale, :headline, :story, :media, :credit, :caption

  validates :headline, :locale, :presence => true
	validates :media, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.errors.messages.invalid_url')},  :if => "!media.blank?"


end
