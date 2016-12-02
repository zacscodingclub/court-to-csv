module CourtToCSV
  class Case
    attr_accessor :case_number, #
                  :name, #
                  :address,
                  :city,
                  :state,
                  :zipcode,
                  :dob,
                  :gender,
                  :race,
                  :county, #
                  :charge_date, # filing date
                  :charge_type, # criminal or traffic
                  :count, # city or county
                  :charge_description,
                  :url
    @@all = []

    def initialize(case_attributes)
      set_attributes(case_attributes)

      get_specific_attributes
    end

    def self.create(case_attributes)
      this_case = new(case_attributes)

      @@all << this_case
    end

    def self.all
      @@all
    end

    def self.reset!
      self.all.clear
    end

    def set_attributes(case_attributes)
      case_attributes.each { |k,v| self.send(("#{k}="), v)}
    end

    def get_specific_attributes
      if charge_type == "traffic"
        new_attributes = CourtToCSV::Scraper.scrape_traffic_case(self)
      else
        new_attributes = CourtToCSV::Scraper.scrape_criminal_case(self)
      end

      set_attributes(new_attributes)
    end

    def full_address
      "#{address}, #{city}, #{state}, #{zipcode}"
    end

    def county_code
      county.include?('count') ? "03" : "24"
    end

    def url
      "http://casesearch.courts.state.md.us/casesearch/inquiryByCaseNum.jis?locationCode=#{county_code}&caseId=#{case_number}&action=Get+Case"
    end
  end
end
