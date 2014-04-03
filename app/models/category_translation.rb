class CategoryTranslation < ActiveRecord::Base
	require 'utf8_converter'
  has_permalink :create_permalink

	belongs_to :category

  attr_accessible :category_id, :name, :locale, :permalink

  validates :name, :permalink, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.name.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
  end


  def create_permalink
    Utf8Converter.convert_ka_to_en(self.name) if self.name
  end

end
