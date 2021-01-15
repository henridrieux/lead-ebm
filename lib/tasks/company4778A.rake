# ----------- OPTICIEN ------------

namespace :company4778a do
  desc "récupérer les company sur Papers.com et les écrire en base"
  # rails company4778a:fetch_compagnies
  task fetch_compagnies: :environment do

    def run_papers(number, date_string, date_end_string)
      APIPapers4778a.new.papers_all(number, date_string, date_end_string)
    end
    run_papers(9000, "01-01-1900", "31-12-1950")
    p "1950 ok"
    run_papers(9000, "01-01-1951", "31-12-1965")
    p "1965 ok"
    run_papers(9000, "01-01-1966", "31-12-1970")
    p "1970 ok"
    run_papers(9000, "01-01-1971", "31-12-1980")
    p "1980 ok"
    run_papers(9000, "01-01-1981", "31-12-1982")
    run_papers(9000, "01-01-1983", "31-12-1984")
    run_papers(9000, "01-01-1985", "31-12-1986")
    run_papers(9000, "01-01-1987", "31-12-1988")
    run_papers(9000, "01-01-1989", "31-12-1989")
    run_papers(9000, "01-01-1990", "31-12-1990")
    p "1990 ok"
    run_papers(9000, "01-01-1991", "31-12-1991")
    run_papers(9000, "01-01-1992", "31-12-1992")
    run_papers(9000, "01-01-1993", "31-12-1993")
    run_papers(9000, "01-01-1994", "31-12-1994")
    run_papers(9000, "01-01-1995", "31-12-1995")
    run_papers(9000, "01-01-1996", "31-12-1996")
    run_papers(9000, "01-01-1997", "31-12-1997")
    run_papers(9000, "01-01-1998", "31-12-1998")
    run_papers(9000, "01-01-1999", "31-12-1999")
    run_papers(9000, "01-01-2000", "31-12-2000")
    p "2000 ok"
    run_papers(9000, "01-01-2001", "31-12-2001")
    run_papers(9000, "01-01-2002", "31-12-2002")
    run_papers(9000, "01-01-2003", "31-12-2003")
    run_papers(9000, "01-01-2004", "31-12-2004")
    run_papers(9000, "01-01-2005", "31-12-2005")
    run_papers(9000, "01-01-2006", "31-12-2006")
    run_papers(9000, "01-01-2007", "31-12-2007")
    run_papers(9000, "01-01-2008", "31-12-2008")
    run_papers(9000, "01-01-2009", "31-12-2009")
    run_papers(9000, "01-01-2010", "31-12-2010")
    p "2010 ok"
    run_papers(9000, "01-01-2011", "31-12-2011")
    run_papers(9000, "01-01-2012", "31-12-2012")
    run_papers(9000, "01-01-2013", "31-12-2013")
    run_papers(9000, "01-01-2014", "31-12-2014")
    run_papers(9000, "01-01-2015", "31-12-2015")
    run_papers(9000, "01-01-2016", "31-12-2016")
    run_papers(9000, "01-01-2017", "31-12-2017")
    run_papers(9000, "01-01-2018", "31-12-2018")
    run_papers(9000, "01-01-2019", "31-12-2019")
    run_papers(9000, "01-01-2020", "31-12-2020")
    p "2020 ok"
    run_papers(9000, "01-01-2021", "31-12-2021")
  end
end



