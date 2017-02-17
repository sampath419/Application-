module Services
  class Store
    include HTTParty
    base_uri 'rti-app01-maha.apple.com'

    def initialize(dsid)
      @dsid=dsid
    end

    def locations
      self.class.get("/employee_location/#{@dsid}.json")
    end
  end
end