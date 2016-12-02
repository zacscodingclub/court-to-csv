module CourtToCSV
  class CLI
    def call
      puts "CourtToCSV Entry Point"
      clear_tmp

      CourtToCSV::Scraper.call
      csv_files = Dir['./tmp/*.csv']

      csv_files.each do |file|
        CourtToCSV::Something.csv_to_cases(file)
      end

      all_cases = CourtToCSV::Case.all
      binding.pry
      CourtToCSV::Something.cases_to_csv(all_cases)

      puts "All Done.  A total of #{all_cases.size} cases were written to the results.csv"
      clear_tmp
    end

    def clear_tmp
      system('rm -rf tmp')
      system('mkdir tmp')
    end
  end
end
