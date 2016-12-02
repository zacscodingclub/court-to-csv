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
                  :charge_date, # filing date
                  :charge_type, # criminal or traffic
                  :count, # city or county
                  :charge_description,
                  :url
    @@all = []

    def initialize(case_attributes)
      case_attributes.each { |k,v| self.send(("#{k}="), v)}
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

    def full_address
      "#{address}, #{city}, #{state}, #{zipcode}"
    end
  end
end
