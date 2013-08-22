#Election Timeline

This is a rails app that uses timeline.js to render events in a nice timeline format.  Features of the site include:
* TimelineJS - https://github.com/VeriteCo/TimelineJS/
* generating and caching json files of timeline data from database so pages load quicker
* automatically saving images locally to avoid issues of images disappearing on the web
 

##TimelineJS Tweaks
The following code changes were applied for to the timeline:
* not using the timeline tag system so using styles to hide that
* override styles in vendor/assets/stylesheets/timeline.css at the bottom
* js/css locations
  * storyjs-embed.js contains settings for where the timeline js and css files are located. In dev mode, these are at the root while in prod these are under the assets folder.  The following changes where made to accomadate this.
    * layout/timeline.html.erb - in js, added the following:
      ```javascript
			var asset_location = '';
			<% if !Rails.env.development? %>
			  asset_location = 'assets/';
			<% end %>
      ```
    * in storyjs-embed.js, changed css and js embed path to:
    ```javascript
    css:embed_path+"/"+asset_location,js:embed_path+"/"+asset_location
    ```
    * in config/application.rb, add paths to assets so that they will exist as separate files
    ```ruby 
    config.assets.precompile += ['fonts_en.css', 'fonts_ka.css', 'timeline-min.js', 'timeline.css']
    ```
