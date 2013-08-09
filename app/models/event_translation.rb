class EventTranslation < ActiveRecord::Base
  require "open-uri"
	require 'utf8_converter'

	belongs_to :event
	has_attached_file :media_img, :url => "/system/media_img/:id/:filename"

  attr_accessible :event_id, :locale, :headline, :story, :media, :credit, :caption,
    :media_img, :media_img_file_name, :media_img_content_type, :media_img_file_size, :media_img_updated_at, :media_img_verified
	attr_accessor :media_original

  validates :headline, :locale, :presence => true
	validates :media, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.errors.messages.invalid_url')},  :if => "!media.blank?"
	validates :media, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('activerecord.errors.messages.invalid_url')},  :if => "!media.blank?"


	after_find :set_original_values
  before_save :create_media_file

	def set_original_values
		self.media_original = self.has_attribute?(:media) ? self.media : nil
	end

  # if the url in the media field is for an image
  # download it and save to media_img
  def create_media_file
    if self.media.present? && ((self.media != self.media_original) || (!self.media_img_verified && self.media_img_file_name.blank?))
      begin
        file = open(self.media)
        if file.present?
          case file.content_type
          when "image/png", "image/gif", "image/jpeg"
            # create the file name that paperclip will read in
            extension = File.extname(URI.parse(self.media).path)
            # if extension is not in url, us the content type
            # if extension is php (e.g., http://www.tbilisi.gov.ge/functions/img.php?src_jpg=../album/1297_5992_668123.jpg&im_new_w=500)
            # - default to content type to get true content type
            extension = "." + file.content_type.split('/')[1] if !extension.present? || extension == '.php'
            name = "media_img"
            name = Utf8Converter.generate_permalink(self.headline) if self.headline.present?

            file.define_singleton_method(:original_filename) do
              "#{name}#{extension}"
            end
            self.media_img = file
          end
          self.media_img_verified = true
        end
      rescue OpenURI::HTTPError => the_error
        self.media_img_verified = true
      end
    # if media is no longer present, delete image file
    elsif !self.media.present? && self.media != self.media_original
      self.media_img_verified = false
      self.media_img = nil
    end
  end


  def media_url
    if self.media_img_file_name.present?
      self.media_img.url
    else
      self.media
    end
  end

end
