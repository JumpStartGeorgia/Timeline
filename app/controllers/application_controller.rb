class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  protect_from_forgery

	before_filter :set_locale
#	before_filter :is_browser_supported?
	before_filter :initialize_gon
	before_filter :preload_global_variables

	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_url, :alert => exception.message
    end
	end

	Browser = Struct.new(:browser, :version)
	SUPPORTED_BROWSERS = [
		Browser.new("Chrome", "15.0"),
		Browser.new("Safari", "4.0.2"),
		Browser.new("Firefox", "10.0.2"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
logger.debug "////////////////////////// BROWSER = #{user_agent}"
		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
			# browser not supported
logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
			render "layouts/unsupported_browser", :layout => false
		end
	end

	def preload_global_variables
    @categories = Category.by_type(Category::TYPES[:category]).with_events
	end

	def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
	end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

	def initialize_gon
		gon.set = true
		gon.highlight_first_form_field = true
	end

	def after_sign_in_path_for(resource)
		root_path
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end

  #######################
  def build_story(story, categories, tags, id)
    x = "<input type='hidden' class='hidden_input_id' id='hidden_input_" + id.to_s + "' value='" + id.to_s + "' />" # to find this from javascript

    if categories.present? || tags.present?
      x << "<div class='story_cat_tags fluid-row clear'>"
=begin
      if categories.present?
        x << "<div class='span6'>"
        x << "<strong>#{I18n.t('categories.category')}:</strong> "
        x << categories.sort_by{|y| y[:name]}.map{|x| view_context.link_to(x[:name], root_path(:category => x[:permalink], :locale => I18n.locale))}.join(", ")
        x << "</div>"
      end
=end      
      if tags.present?
#        x << "<div class='span6'>"
        x << "<div class='span12'>"
#        x << "<strong>#{I18n.t('categories.tag')}:</strong> "
        x << "#{I18n.t('categories.tag')}: "
        x << tags.sort_by{|y| y[:name]}.map{|x| view_context.link_to(x[:name], url_for(params.merge(:tag => x[:permalink], :locale => I18n.locale)))}.join(" ")
        x << "</div>"
      end
      x << "</div>"
    end

    x << view_context.simple_format(story.clone) if story.present?

    # add social links

    x << "<div class='event_social_links'>"
    img = 'http://dev-etimeline.jumpstart.ge/system/media_img/245/baqradze_nacionaluri_modzraobis_saprezidentho_kandidathi.jpg?1375784280';
    x << '<a class="fbshare" title="Share on Facebook" href="" target="_blank"><img src="http://w.sharethis.com/images/facebook_counter.png" alt="Share on Facebook" /></a>'
   #x << "  <span class='st_facebook_hcount' displayText='Facebook'></span>"
   #x << "  <span class='st_googleplus_hcount' displayText='Google +'></span>"
    x << "  <span class='st_twitter_hcount' displayText='Tweet'></span>"
    x << "  <span class='st_sharethis_hcount' displayText='ShareThis'></span>"
    x << "</div>"


    return x
  end

  #######################
	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

end
