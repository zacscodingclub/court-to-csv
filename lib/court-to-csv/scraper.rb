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

      date_range.each do |date|
        search_params.each do |params|
          file = scrape_court(date, params)

          if file
            new_filename = "#{date.tr(' ', '_')}_#{params[:county_name].tr(' ','_')}_#{params[:site]}.csv".downcase
            puts "Writing to #{new_filename}"
            file.save "tmp/#{new_filename}"
          end

          sleep(0.4)
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

      if mech.page.link_with(:text => 'CSV ')
        mech.page.link_with(:text => 'CSV ').click
      end
    end

    def self.scrape_traffic_case(traffic_case)
      mech = self.mechanize_setup
      mech.get(GATEWAY_URL)

      mech.post(traffic_case.url)
      sleep(0.4)
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
      mech = self.mechanize_setup
      mech.get(GATEWAY_URL)

      mech.post(criminal_case.url)
      circuit_and_city = mech.page.search('.Header').text.include?("Circuit") && criminal_case.county != 'county'

      charges = circuit_and_city ? self.get_charges_from_circuit(mech.page) : self.get_charges_from_district(mech.page)
      address = circuit_and_city ? mech.page.search('table:nth-child(9) .Value').text : mech.page.search('table:nth-child(10) .Value').children[0].text
      gender = circuit_and_city ? mech.page.search('table:nth-child(8) .Value')[1].text : mech.page.search('table:nth-child(9) tr+ tr .Value:nth-child(1)').text
      race = self.scrape_race(mech.page)

      sleep(0.4)
      {
                 address: address,
                    city: self.getNextElement(mech.page.search("[text()*='City:']")[0]).children[0].text,
                   state: self.getNextElement(mech.page.search("[text()*='City:']")[0]).children[2].text,
                 zipcode: self.getNextElement(mech.page.search("[text()*='City:']")[0]).children[4].text,
                     dob: mech.page.search('table:nth-child(9)').search("[text()*='/']").text,
                  gender: gender,
                    race: race,
      charge_description: charges
      }
    end

    def self.getNextElement(el)
      el.parent.next_element
    end

    def self.scrape_race(page)
      page.search("[text()*='Race:']").empty? ? "UNK" : self.getNextElement(page.search("[text()*='Race:']")[0]).text
    end

    def self.scrape_criminal_circuit_case(page)
      {
              address: page.search('table:nth-child(9) .Value').text,
                 city: page.search('table:nth-child(10) .Value').children[0].text,
                state: page.search('table:nth-child(10) .Value').children[1].text,
              zipcode: page.search('table:nth-child(10) .Value').children.last.text,
                  dob: page.search('table:nth-child(8) .Value').last.text,
               gender: page.search('table:nth-child(8) .Value')[1].text,
                 race: page.search('table:nth-child(8) .Value')[0].text,
   charge_description: self.get_charges_from_circuit(page)
      }
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
   charge_description: self.get_charges_from_district(page)
      }
    end

    def self.get_charges_from_circuit(page)
      page.search('.AltBodyWindow1').map do |charge|
        charge.search('.Value').last.text
      end
    end
    def self.get_charges_from_district(page)
      page.search('.AltBodyWindow1').map do |charge|
        charge.search('.Prompt+.Value')[0].text
      end
    end
  end
end
