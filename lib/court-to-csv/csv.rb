require 'csv'

module CourtToCSV
  class CSVHandler
    def self.csv_to_cases(file)
      type = file.include?('crim') ? 'criminal' : 'traffic'
      county = file.include?('city') ? 'city' : 'county'

      CSV.foreach(file) do |row|
        CourtToCSV::Case.create({
          case_number: row[0],
                 name: row[1],
               county: county,
          charge_type: type,
          charge_date: row[7]
        })
          sleep(0.5)
      end
    end

    def self.cases_to_csv(cases)
      headers = ["Case Number", "Name", "Address", "City", "State", "Zip Code", "Date of Birth", "Gender", "Race", "Charge Date", "Charge Description"]
    end
  end
end
