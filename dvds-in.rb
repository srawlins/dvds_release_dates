require File.join(File.dirname(__FILE__), 'dvds_release_dates')

year  = ARGV.shift || 2012
month = ARGV.shift || "1..12"
if month =~ /^(\d+)\.\.(\d+)$/
  month = Range.new($1.to_i, $2.to_i).to_a
  months = month.size-1
elsif month =~ /^(\d+)$/
  month = Range.new($1.to_i, $1.to_i).to_a
  months = month.size-1
elsif month =~ /^(\d+)\+(\d+)$/
  month = Range.new($1.to_i, $1.to_i).to_a
  months = $2.to_i
end

d = DVDsReleaseDates.new("http://www.dvdsreleasedates.com/releases/#{year}/#{month[0]}/DVD-Releases-#{Date::MONTHNAMES[month[0]]}-#{year}.html")
months.times do |i|
  d.add_next
end
puts d.urls
d.parse
d.select {|t| t[:imdb] > 6 }
d.select {|t| not t[:title] =~ /Season( \d+(\.\d+)?)?$/ }
d.select {|t| not t[:title] =~ /: Season \w+$/ }
d.select {|t| not t[:title] =~ /[,:] Volume \d+$/ }
d.print {|t| t[:imdb] }
