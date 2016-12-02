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
          sleep(0.2)
        end
      end
    end

    def self.mechanize_setup
      mech = Mechanize.new
      mech.user_agent = 'Windows Mozilla'
      mech
    end

    def self.scrape_court(date, search_params)
      mech = self.mechanize_setup
      mech.get(GATEWAY_URL)

      puts "Downloading #{search_params[:site]} data from #{date.tr(' ', '/')}, #{search_params[:county_name]} "
      mech.post("http://casesearch.courts.state.md.us/casesearch/inquirySearch.jis?lastName=+&firstName=&middleName=&partyType=DEF&site=#{search_params[:site]}&courtSystem=B&countyName=#{search_params[:county_name].tr(' ', '+')}&filingStart=&filingEnd=&filingDate=#{date.gsub(' ', '%2F')}&company=N&action=Search")

      mech.page.link_with(:text => 'CSV ').click
    end

    def self.scrape_traffic_case(traffic_case)
      mech = self.mechanize_setup
      mech.get(GATEWAY_URL)

      mech.post(traffic_case.url)

      {
              address: mech.page.search('h5~ table+ table td')[0].children.last.text,
                 city: mech.page.search('h5~ table+ table td')[2].children[0].text,
                state: mech.page.search('h5~ table+ table td')[2].children[2].text,
              zipcode: mech.page.search('h5~ table+ table td')[2].children[4].text,
                  dob: mech.page.search('h5~ table+ table td')[5].children.last.text,
               gender: mech.page.search('h5~ table+ table td')[4].children[1].text,
                 race: mech.page.search('h5~ table+ table td')[3].children.last.text,
   charge_description: mech.page.search('.AltBodyWindow1 tr+ tr .Value').text
      }
    end

    def self.scrape_criminal_case(criminal_case)
      binding.pry
      mech = self.mechanize_setup
      mech.get(GATEWAY_URL)

      mech.post(criminal_case.url)

      if mech.page.search('.Header').text.include?("Circuit")
        self.scrape_criminal_circuit_case(mech.page)
      else
        self.scrape_criminal_district_case(mech.page)
      end
    end

    def self.scrape_criminal_circuit_case(page)
      binding.pry
    end

    def self.scrape_criminal_district_case(page)
      {
              address: page.search('table:nth-child(10) .Value').children[0].text,
                 city: page.search('table:nth-child(10) .Value').children[1].text,
                state: page.search('table:nth-child(10) .Value').children[2].text,
              zipcode: page.search('table:nth-child(10) .Value').children.last.text,
                  dob: page.search('.Value:nth-child(7)').children[0].text,
               gender: page.search('table:nth-child(9) tr+ tr .Value:nth-child(1)').text,
                 race: page.search('table:nth-child(9) tr:nth-child(1) .Value').text,
   charge_description: self.get_charges(page)
      }
    end

    def self.get_charges(page)
      page.search('.AltBodyWindow1').map do |charge|
        charge.search('.Prompt+.Value')[0].text
      end
    end
  end
end
