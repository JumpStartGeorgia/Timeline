module LoadData
	require 'net/http'
	require 'net/https'

  def self.google_spreadsheet_json(url)
    
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    json = response.body
    if json.present?
      # format the json into the format we need
      formatted_json = []
      json_data = JSON.parse(json)["feed"]["entry"]
      json_data.each do |j|
        h = Hash.new
        formatted_json << h

        if j["gsx$startdate"]["$t"].present? && j["gsx$startdate"]["$t"].index(":").present?
          h["start_date"] = Date.strptime(j["gsx$startdate"]["$t"], '%m/%d/%Y')
#          h["start_time"] = Time.strptime(j["gsx$startdate"]["$t"].split(' ')[1], '%H:%M')
          h["start_time"] = j["gsx$startdate"]["$t"].split(' ')[1]
        elsif j["gsx$startdate"]["$t"].present?
          h["start_date"] = Date.strptime(j["gsx$startdate"]["$t"], '%m/%d/%Y')
          h["start_time"] = nil
        else
          h["start_date"] = nil
          h["start_time"] = nil
        end

        if j["gsx$enddate"]["$t"].present? && j["gsx$enddate"]["$t"].index(":").present?
          h["end_date"] = Date.strptime(j["gsx$enddate"]["$t"], '%m/%d/%Y')
#          h["end_time"] = Time.strptime(j["gsx$enddate"]["$t"].split(' ')[1], '%H:%M')
          h["end_time"] = j["gsx$enddate"]["$t"].split(' ')[1]
        elsif j["gsx$enddate"]["$t"].present?
          h["end_date"] = Date.strptime(j["gsx$enddate"]["$t"], '%m/%d/%Y')
          h["end_time"] = nil
        else
          h["end_date"] = nil
          h["end_time"] = nil
        end

        h["event_type"] = j["gsx$type"]["$t"].present? ? j["gsx$type"]["$t"] : nil
        h["headline"] = j["gsx$headline"]["$t"].present? ? j["gsx$headline"]["$t"] : nil
        h["story"] = j["gsx$text"]["$t"].present? ? j["gsx$text"]["$t"] : nil
        h["media"] = j["gsx$media"]["$t"].present? ? j["gsx$media"]["$t"] : nil
        h["credit"] = j["gsx$mediacredit"]["$t"].present? ? j["gsx$mediacredit"]["$t"] : nil
        h["caption"] = j["gsx$mediacaption"]["$t"].present? ? j["gsx$mediacaption"]["$t"] : nil
      end
      Event.load_from_json(formatted_json)
    end

    return nil
  end

end

