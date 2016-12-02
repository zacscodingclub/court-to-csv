require 'csv'

module CourtToCSV
  class CSVHandler
    def self.csv_to_cases(file)
      type = file.include?('crim') ? 'criminal' : 'traffic'
      county = file.include?('cit') ? 'city' : 'county'
      line_count = `wc -l "#{file}"`.strip.split(' ')[0].to_i

      CSV.foreach(file).with_index do |row, index|
        print "  Downloading line #{index + 1}/#{line_count}\r"
        CourtToCSV::Case.create({
          case_number: row[0],
                 name: row[1],
               county: county,
          charge_type: type,
          charge_date: row[7]
        })
        $stdout.flush
      end
    end

    def self.cases_to_csv(cases)
      headers = ["Case Number", "Name", "Address", "City", "State", "Zip Code", "Date of Birth", "Gender", "Race", "Charge Date", "Charge Description"]

      CSV.open('results/output.csv', 'wb') do |csv|
        csv << headers

        cases.each do |case_details|
          csv << case_details.to_csv
        end
      end
    end
  end
end
