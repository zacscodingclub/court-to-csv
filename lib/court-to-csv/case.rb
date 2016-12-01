class CourtToCSV::Case
  attr_accessor :case_number,
                :name,
                :address,
                :city,
                :state,
                :zipcode,
                :dob,
                :gender,
                :race,
                :charge_date,
                :charge_description
  @@all = []

  def initialize(case_attributes)
    case_attributes.each { |k,v| self.send(("#{k}="), v)}

    @@all << self
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
