namespace :fix_images do

	##############################
  desc "reprocess images that use php to load the image"
  task :php_paths => [:environment] do
    require 'json_cache'
    counter = 0
    EventTranslation.transaction do 
      trans = EventTranslation.where("media like '%.php%' and media_img_content_type like 'image/%'")
      trans.each do |t|
        # to make image reload, have to clear out media url and then replace it
        media = t.media
        t.media = nil
        t.save
        t.media = media
        t.save
        counter += 1 
      end
    end
  end



end
