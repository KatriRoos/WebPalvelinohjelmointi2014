class BeermappingApi
  def self.places_in(city)
    city = city.downcase
    Rails.cache.fetch(city, expires_in:expiry_time) { fetch_places_in(city) }
  end

  def self.find(id, city)
    places_in(city).select{ |p| p.id==id.to_s }.first
  end

  private

  def self.fetch_places_in(city)
    #url = "http://beermapping.com/webservice/loccity/#{key}/"
    #url = "http://localhost:3001/api/"
    url = "http://stark-oasis-9187.herokuapp.com/api/"

    response = HTTParty.get "#{url}#{ERB::Util.url_encode(city)}"
    places = response.parsed_response["bmp_locations"]["location"]

    return [] if places.is_a?(Hash) and places['id'].nil?

    places = [places] if places.is_a?(Hash)
    places.inject([]) do | set, place |
      set << Place.new(place)
    end
  end

  def self.raw(city)
    city = city.downcase
    Rails.cache.fetch(city.upcase, expires_in:expiry_time) { fetch_raw(city) }
  end

  def self.fetch_raw(city)
    url = "http://beermapping.com/webservice/loccity/#{key}/"

    response = HTTParty.get "#{url}#{ERB::Util.url_encode(city)}"
    response.parsed_response["bmp_locations"]
  end

  def self.key
    Settings.beermapping_apikey
  end

  def self.expiry_time
    1.week
  end
end