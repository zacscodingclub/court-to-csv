require 'csv'

module CourtToCSV
  class Something
    def self.csv_to_cases(file)
      CSV.foreach(file) do |row|
        CourtToCSV::Case.create({
          case_number: row[0],
                 name: row[1],
          charge_type: row[5],
          charge_date: row[7]
        })
      end
    end

    def self.cases_to_csv(cases)
      headers = ["Case Number", "Name", "Address", "City", "State", "Zip Code", "Date of Birth", "Gender", "Race", "Charge Date", "Charge Description"]
    end
  end
end
