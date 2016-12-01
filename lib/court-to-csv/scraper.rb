require 'pry'
class CourtToCSV::Scraper
  def self.call
    date_range = ((Date.today - 4)..Date.today).map{|d|  d.strftime("%m %d %Y")}
    search_params = [
      { site:"CRIMINAL", county_name:"BALTIMORE+CITY" },
      { site:"TRAFFIC", county_name:"BALTIMORE+CITY" },
      { site:"CRIMINAL", county_name:"BALTIMORE+COUNTY" },
      { site:"TRAFFIC", county_name:"BALTIMORE+COUNTY" },
    ]

    # O(n^2) for now... but not too worried since
    # getting charge description is bulk of HTTP calls
    date_range.each do |date|
      search_params.each do |params|
        file = scrape_court(date, params)

        file.save "tmp/#{date.tr(' ', '_')}_#{params[:county_name].tr('+','_')}_#{params[:site]}.csv"
      end
    end
  end

  def self.scrape_court(date, search_params)
    mech = Mechanize.new
    mech.user_agent = 'Windows Mozilla'

    mech.get("http://casesearch.courts.state.md.us/casesearch/processDisclaimer.jis?disclaimer=Y")
    mech.post("http://casesearch.courts.state.md.us/casesearch/inquirySearch.jis?lastName=+&firstName=&middleName=&partyType=DEF&site=#{search_params[:site]}&courtSystem=B&countyName=#{search_params[:county_name]}&filingStart=&filingEnd=&filingDate=#{date.gsub(' ', '%2F')}&company=N&action=Search")

    mech.page.link_with(:text => 'CSV ').click
  end

  def self.scrape_by_case_number(case_number)

  end

  def self.test_scrape
    binding.pry
  end

  def self.test_url

  end
end
