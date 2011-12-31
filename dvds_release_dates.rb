require 'nokogiri'
require 'open-uri'
require 'date'

class DVDsReleaseDates
  attr_accessor :urls

  def initialize(url)
    @urls = [url]
    if url =~ /(\d+)\/(\d+)\/DVD-Releases-(\w+)-(\d+).html/
      @year  = $1.to_i
      @month = $2.to_i
      puts "Month: #{$3}, Month Number: #{$2}"
    end
    @titles = {}
  end

  def add_next
    @year += 1 if @month == 12
    @month = @month % 12 + 1
    if @urls.last =~ /(\d+)\/(\d+)\/DVD-Releases-(\w+)-(\d+).html/
      @urls << @urls.last.gsub(/(\d+)\/(\d+)\/DVD-Releases-(\w+)-(\d+).html/) do |m|
        "#{@year}/#{@month}/DVD-Releases-#{Date::MONTHNAMES[@month]}-#{@year}.html"
      end
    end
  end

  def parse
    @urls.each do |url|
      @document = Nokogiri::HTML(open(url))
      @document.xpath("//td[@class='reldate']").each do |week|
        @titles[week.content] = []
        week.xpath("../../tr/td[@class='dvdcell']").each do |title_node|
          title_title = title_node.xpath("text()[1]").first.content.strip
          imdb_rating = title_node.xpath("span[@class='imdblink']/a").first.content.to_f
          dvd_price = title_node.xpath("div[@class='divcelltype' and text()='DVD']").first
          unless dvd_price.nil?
            dvd_price = title_node.xpath("div[@class='divcelltype' and text()='DVD']/following-sibling::div[@class='divcellprice']/a/text()").first.content.sub(/\$/, '').to_f
          end
          bluray_price = title_node.xpath("div[@class='divcelltype' and text()='Blu-ray']").first
          unless bluray_price.nil?
            bluray_price = title_node.xpath("div[@class='divcelltype' and text()='Blu-ray']/following-sibling::div[@class='divcellprice']/a/text()").first.content.sub(/\$/, '').to_f
          end
          title = {:title => title_title, :imdb => imdb_rating, :dvd_price => dvd_price, :bluray_price => bluray_price}
          @titles[week.content] << title
        end
      end
    end
  end

  def print(&block)
    @titles.each do |week, titles|
      next if titles.empty?
      puts week
      sorted_titles = titles
      sorted_titles = titles.sort_by(&block) if block
      sorted_titles.each do |title|
        puts "  #{title[:title]} (IMDb: #{title[:imdb]}, DVD Price: #{title[:dvd_price]}, Blu-ray Price: #{title[:bluray_price]})"
      end
    end
  end

  def select(&block)
    @titles.map do |week, titles|
      titles.select!(&block)
    end
  end
end

