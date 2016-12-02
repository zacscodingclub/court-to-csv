module CourtToCSV
  class CLI
    def call
      puts "CourtToCSV Entry Point"
      clear_tmp

      CourtToCSV::Scraper.call
      csv_files = Dir['./tmp/*.csv']

      csv_files.each_with_index do |file, index|
        puts "Processing file #{index + 1}/#{csv_files.size}             \n"
        CourtToCSV::CSVHandler.csv_to_cases(file)
      end

      all_cases = CourtToCSV::Case.all

      CourtToCSV::CSVHandler.cases_to_csv(all_cases)

      puts "All Done.  A total of #{all_cases.size} cases were written to the results/output.csv"
      clear_tmp
    end

    def clear_tmp
      system('rm -rf tmp')
      system('mkdir tmp')
    end
  end
end
