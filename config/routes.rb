BootstrapStarter::Application.routes.draw do


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
      resources :events
      resources :categories
		end


		root :to => 'root#index'
	  match "*path", :to => redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
	end

	match '', :to => redirect("/#{I18n.default_locale}") # handles /
	match '*path', :to => redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

end
