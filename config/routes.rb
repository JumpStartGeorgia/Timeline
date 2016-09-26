require 'robots_generator'

BootstrapStarter::Application.routes.draw do


  # user robots generator to avoid non-production sites from being indexed
  match '/robots.txt' => RobotsGenerator

	#--------------------------------
	# all resources should be within the scope block below
	#--------------------------------
	scope ":locale", locale: /#{I18n.available_locales.join("|")}/ do


		devise_for :users, :path_names => {:sign_in => 'login', :sign_out => 'logout'}

		match '/admin', :to => 'admin#index', :as => :admin, :via => :get
		match '/admin/about', :to => 'admin#about', :as => :admin_about, :via => :get
		match '/admin/about', :to => 'admin#about', :as => :admin_about, :via => :post


		namespace :admin do
			resources :users
      resources :events do
        collection do
          post 'reload_data'
        end
      end
      resources :categories
		end

		match "/fb_record/:id", :to => 'root#fb_record', :as => :fb_record, :via => :get, :defaults => {:format => 'json'}
    match "/timeline_events", :to => 'root#timeline_events', :via => :get, :defaults => {:format => 'json'}

		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
