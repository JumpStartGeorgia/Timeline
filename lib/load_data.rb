module LoadData
	require 'net/http'
	require 'net/https'
  require 'json_cache'

  def self.google_spreadsheet_json_multi_lang(ka_url, en_url)
puts 'getting en'
    en_json = format_data(en_url)
puts 'getting ka'
    ka_json = format_data(ka_url)
  
    if en_json.present? && ka_json.present?
puts 'creating records'
      Event.load_from_json_multi_lang(ka_json, en_json)

      # clear the cache files so the new data is avaialble
      JsonCache.clear
    end

    return nil
  end

  def self.google_spreadsheet_json(url)

    json = format_data(url)
    if json.present?
      Event.load_from_json(json)

      # clear the cache files so the new data is avaialble
      JsonCache.clear
    end

    return nil
  end


protected 
  def self.format_data(url)
    formatted_json = []
    
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    json = response.body
    if json.present?
      # format the json into the format we need
      json_data = JSON.parse(json)["feed"]["entry"]
      json_data.each do |j|
        h = Hash.new
        formatted_json << h

        begin
          if j["gsx$startdate"].present? && j["gsx$startdate"]["$t"].present? && j["gsx$startdate"]["$t"].index(":").present?
            h["start_date"] = Date.strptime(j["gsx$startdate"]["$t"], '%m/%d/%Y')
#           h["start_time"] = Time.strptime(j["gsx$startdate"]["$t"].split(' ')[1], '%H:%M')
            h["start_time"] = j["gsx$startdate"]["$t"].split(' ')[1]
          elsif j["gsx$startdate"].present? && j["gsx$startdate"]["$t"].present?
            h["start_date"] = Date.strptime(j["gsx$startdate"]["$t"], '%m/%d/%Y')
            h["start_time"] = nil
          else
            h["start_date"] = nil
            h["start_time"] = nil
          end
        rescue
          h["start_date"] = nil
          h["start_time"] = nil
        end

        begin
          if j["gsx$enddate"].present? && j["gsx$enddate"]["$t"].present? && j["gsx$enddate"]["$t"].index(":").present?
            h["end_date"] = Date.strptime(j["gsx$enddate"]["$t"], '%m/%d/%Y')
#           h["end_time"] = Time.strptime(j["gsx$enddate"]["$t"].split(' ')[1], '%H:%M')
            h["end_time"] = j["gsx$enddate"]["$t"].split(' ')[1]
          elsif j["gsx$enddate"].present? && j["gsx$enddate"]["$t"].present?
            h["end_date"] = Date.strptime(j["gsx$enddate"]["$t"], '%m/%d/%Y')
            h["end_time"] = nil
          else
            h["end_date"] = nil
            h["end_time"] = nil
          end
        rescue
          h["end_date"] = nil
          h["end_time"] = nil
        end

        h["id"] = j["gsx$id"].present? && j["gsx$id"]["$t"].present? ? j["gsx$id"]["$t"].strip() : nil
        h["event_type"] = j["gsx$type"].present? && j["gsx$type"]["$t"].present? ? j["gsx$type"]["$t"] : nil
        h["headline"] = j["gsx$headline"].present? && j["gsx$headline"]["$t"].present? ? j["gsx$headline"]["$t"] : nil
        h["story"] = j["gsx$text"].present? && j["gsx$text"]["$t"].present? ? j["gsx$text"]["$t"] : nil
        h["media"] = j["gsx$media"].present? && j["gsx$media"]["$t"].present? ? j["gsx$media"]["$t"] : nil
        h["credit"] = j["gsx$mediacredit"].present? && j["gsx$mediacredit"]["$t"].present? ? j["gsx$mediacredit"]["$t"] : nil
        h["caption"] = j["gsx$mediacaption"].present? && j["gsx$mediacaption"]["$t"].present? ? j["gsx$mediacaption"]["$t"] : nil
        h["category"] = j["gsx$category"].present? && j["gsx$category"]["$t"].present? ? j["gsx$category"]["$t"] : nil
      end
    end

    return formatted_json
  end

end

