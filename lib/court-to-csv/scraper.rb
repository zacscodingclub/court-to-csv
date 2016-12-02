require 'pry'
module CourtToCSV
  class Scraper
    GATEWAY_URL = "http://casesearch.courts.state.md.us/casesearch/processDisclaimer.jis?disclaimer=Y"

    def self.call
      date_range = ((Date.today - 4)..Date.today).map{|d|  d.strftime("%m %d %Y")}
      search_params = [
        { site:"CRIMINAL", county_name:"BALTIMORE CITY" },
        { site:"TRAFFIC", county_name:"BALTIMORE CITY" },
        { site:"CRIMINAL", county_name:"BALTIMORE COUNTY" },
        { site:"TRAFFIC", county_name:"BALTIMORE COUNTY" },
      ]

      # O(n^2) for now... but not too worried since
      # getting charge description is bulk of HTTP calls
      date_range.each do |date|
        search_params.each do |params|
          file = scrape_court(date, params)

          new_filename = "#{date.tr(' ', '_')}_#{params[:county_name].tr(' ','_')}_#{params[:site]}.csv".downcase
          puts "Writing to #{new_filename}"
          file.save "tmp/#{new_filename}"
        end
      end
    end

    def self.scrape_court(date, search_params)
      mech = Mechanize.new
      mech.user_agent = 'Windows Mozilla'

      mech.get(GATEWAY_URL)
      puts "Downloading #{search_params[:site]} data from #{date.tr(' ', '/')}, #{search_params[:county_name]} "
      mech.post("http://casesearch.courts.state.md.us/casesearch/inquirySearch.jis?lastName=+&firstName=&middleName=&partyType=DEF&site=#{search_params[:site]}&courtSystem=B&countyName=#{search_params[:county_name].tr(' ', '+')}&filingStart=&filingEnd=&filingDate=#{date.gsub(' ', '%2F')}&company=N&action=Search")

      mech.page.link_with(:text => 'CSV ').click
    end

    def self.scrape_by_case(court_case)
      # <option value="24">Baltimore City Circuit Court</option>
      # <option value="03">Baltimore County Circuit Court</option>
      mech = Mechanize.new
      mech.user_agent = 'Windows Mozilla'
      mech.get(GATEWAY_URL)
      mech.post("http://casesearch.courts.state.md.us/casesearch/inquiryByCaseNum.jis?locationCode=03&caseId=0C10F81&action=Get+Case")
    end
  end
end
