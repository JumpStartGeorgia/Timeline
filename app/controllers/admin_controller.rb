class AdminController < ApplicationController
  before_filter :authenticate_user!

  def index
    respond_to do |format|
      format.html
    end

  end


  def about
    # get the about text
    if File.exists?(@about_path)
      @about_text = JSON.parse(File.read(@about_path))
    else
      json = {}
      I18n.available_locales.each do |locale|
        json[locale.to_s] = ''
      end
      File.open(@about_path, 'w') { |f| f.write(json.to_json) }
      @about_text = json.to_json
    end
  
    if request.post?
      I18n.available_locales.each do |locale|
        @about_text[locale.to_s] = params["about_#{locale}"]
      end
      File.open(@about_path, 'w') { |f| f.write(@about_text.to_json) }

      flash[:notice] = I18n.t('app.msgs.success_updated', obj: I18n.t('admin.about.title'))
    end

  
    respond_to do |format|
      format.html
    end
  
  end
end
