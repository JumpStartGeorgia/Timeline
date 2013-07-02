class Message
	include ActiveAttr::Model
  include ActiveModel::Validations

	attribute :name
	attribute :email
	attribute :subject
	attribute :event
	attribute :event_date
	attribute :url
	attribute :bcc
	attribute :locale, :default => I18n.locale
  
	attr_accessible :name, :email, :event, :subject, :event_date, :url, :bcc,
    :locale

  validates_presence_of :event
  
end
