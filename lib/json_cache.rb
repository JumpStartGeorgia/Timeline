module JsonCache
	require 'fileutils'

	JSON_ROOT_PATH = "#{Rails.root}/public/system/json"

	###########################################
	### manage files
	###########################################
	def self.read(filename)
		json = nil
		file_path = JSON_ROOT_PATH + "/#{filename}.json"
		if filename.present? && File.exists?(file_path)
			json = File.open(file_path, "r") {|f| f.read()}
		end
		return json
	end

	def self.fetch(filename, &block)
		json = nil
		if filename
			file_path = JSON_ROOT_PATH + "/#{filename}.json"
  		if file_path.present?
			  if File.exists?(file_path)
				  json = File.open(file_path, "r") {|f| f.read()}
			  else
				  # get the json data
				  json = yield if block_given?

				  # create the directory tree if it does not exist
		      if file_path != "."
			      FileUtils.mkpath(File.dirname(file_path))
		      end

				  File.open(file_path, 'w') {|f| f.write(json)}
			  end
      end
		end
		return json
	end

	###########################################
	### clear cache
	###########################################
	def self.clear
		Rails.logger.debug "################## - clearing cache files"
		# don't delete the json folder - delete everything inside it
		FileUtils.rm_rf(Dir.glob(JSON_ROOT_PATH + "/*"))
	end


end
