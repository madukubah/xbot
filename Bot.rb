require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require 'watir-scroll'
require 'net/http'
require 'uri'
require 'json'
$wait = Selenium::WebDriver::Wait.new(:timeout => 15 )

class Bot
    @@browser     
    @@userStorePath
    def initialize( params = {} )
        @@baseUrl = params.fetch(:baseUrl, "https://www.instagram.com/" ) 
        @@browser = Watir::Browser.new :chrome
        @@userStorePath = 'data/users5'
    end

    def setUserStorePath( path )
        @@userStorePath = path
    end
    def setBrowser( browser )
        @@browser = browser
        ap "set browser"
    end


    def login( username, password )
        ap "login..."
        @@browser.goto @@baseUrl  + 'accounts/login/?hl=id'
        @@browser.text_field(:name => "username").set "#{username}"
        @@browser.text_field(:name => "password").set "#{password}"
        @@browser.button(:class => ["sqdOP", "L3NKy", "y3zKF"] ).click

        sleep(5)
        if @@browser.button(:class => ['sqdOP', 'yWX7d', "y3zKF" ] ).exists?
            @@browser.button(:class => ["sqdOP", "L3NKy", "y3zKF"] ).click
        end

        sleep(10)
        if @@browser.button(:class => ['aOOlW', 'HoLwm'] ).exists?
            @@browser.button(:class => ['aOOlW', 'HoLwm'] ).click
        end
    end

    def visitUser( username )
        @@browser.goto @@baseUrl + username # + '/?hl=id'
        # ap  @@browser.manage.logs.get(:browser)
    end

        
    def removeStopWords( text )
        stopWords = [
            'or',
            'and',
            'on',
            'one',
            'possible',
        ]
        text = text.split(' ')
        text = text.reject { |word| stopWords.include?(word) }.join(' ') 
        return text
    end

    def categorizePeople( text )
        # text = "555 people person"
        # puts text.index(/\d+ people/)
        if ! text.match(/\d+ people/)
            return text
        end
        a = text.index(/\d+ people/)
        result =  text[a..text.index(/\d people/)  ].to_i
        # puts result

        if result > 2
            text = text.gsub(/\d+ people/,"xxx")
            text = text.gsub(/person/,"")
            text = text.gsub(/ people/,"")
            text = text.gsub(/xxx/,"people")
            # puts text
        elsif result == 2
            text = text.gsub(/\d+ people/,"couple")
            text = text.gsub(/person/,"")
            text = text.gsub(/ people/,"")
            # puts text
        end

        return text

    end

    def textPreprocessing( text )
        ap text

        text = text.downcase
        if text.include? "image may contain:"
            text = text[(text.index('image may contain:') - 1)..text.length ] 
            text.slice! "image may contain:"
            
        else
            return ''
        end
    
        if text.index('text that says') != nil
            text = text[0..(text.index('that says') - 1)] 
        end
        text = text.gsub(/[,]/ ,"")
        text = text.gsub(/[.]/ ,"")
        # text = text.gsub( 'people' , 'person')
        text = text.gsub( 'more' , '3')
        text = text.strip
        text = removeStopWords( text )
        text = categorizePeople( text )
        text = text.gsub(/\d+/ ,"")
        text = text.strip
        ap "after : #{text}"
        return text
    end

    def followUser( username )
        if @@browser.button(:class => [ "_5f5mN", "jIbKX", "_6VtSN", "yZn4P" ]).exists?
            @@browser.button( :class => [ "_5f5mN", "jIbKX", "_6VtSN", "yZn4P" ] ).click
            sleep(3)
        end
    end

    def scanUserImage( username, limit = NULL )
        begin
            self.visitUser( username )
            images = Array.new #local var
            if @@browser.div(class:"eLAPa").exists?
                @@browser.div(class:"eLAPa").click

                dialogElement = $wait.until { @@browser.div(:class => ["_2dDPU", "CkGkG"]) }
                imageCount = 0
                while dialogElement.link( :class => ["_65Bje", "coreSpriteRightPaginationArrow"] ).exists?
                    if( limit )
                        if(  imageCount > limit )
                            break
                        end
                    end

                    $wait.until { !dialogElement.div(:class => ['jdnLC' ] ).present? }
                    # $wait.until { !dialogElement.div(:class => ['Igw0E', 'IwRSH', 'YBx95', '_4EzTm' ] ).present? } // use it in small screen
                    if dialogElement.div(:class => "KL4Bh").exists?
                        imageDiv =  dialogElement.div(:class => "KL4Bh")
                        ap imageDiv.image.attribute('alt')
                        images.push( {
                            'desc_image' => textPreprocessing( imageDiv.image.attribute('alt') ) ,
                            'source' => imageDiv.image.attribute('src') 
                        })
                    end
                    imageCount = imageCount + 1
                    dialogElement.link( :class => ["_65Bje", "coreSpriteRightPaginationArrow"] ).click
                end
            end
            return images
        rescue
            ap "get rate limit sleep 400 seconds"
            sleep(400)
            self.scanUserImage( username, limit )
        end
    end

    def listingFollowers( username )
        self.visitUser( username )
        @@browser.link(:href => "/#{ username }/followers/").click
        boxFollowerElem = @@browser.div(:class => "PZuss")

        loop do
            boxFollowerElem.scroll.to :bottom
            sleep(1)
        end
    end

    def storeUsersInfile( dir, filename, data )
        File.open( "#{dir}" + "/"+ "#{filename}" +".json","w") do |f|
            f.write( data.to_json)
        end
    end

    def storeListingLastAct( endCursor, page )
        lastAct = { 'endCursor' => endCursor, 'page' => page }
        File.open( "data/last_act.json","w") do |f|
            f.write( lastAct.to_json)
        end  
    end

    def listingFollowersByAPI( queryHash, endCursor, page = 1 )
        @@browser.goto 'https://www.instagram.com/graphql/query/?query_hash='+ queryHash +'&variables=%7B%22id%22%3A%224492076266%22%2C%22include_reel%22%3Atrue%2C%22fetch_mutual%22%3Afalse%2C%22first%22%3A12%2C%22after%22%3A%22'+ endCursor +'%3D%3D%22%7D'
        pageContent = @@browser.body().text
        jsonData = JSON.parse( pageContent )
        begin
            hasNextPage = jsonData['data']['user']['edge_followed_by']['page_info']['has_next_page']
            if( hasNextPage )
                endCursor   = jsonData['data']['user']['edge_followed_by']['page_info']['end_cursor']
                users       = jsonData['data']['user']['edge_followed_by']['edges']
    
                userArr = Array.new #local var
                users.each do |user|
                    user['node']['reel'] = ''
                    userArr.push( user['node'] )
                end
                self.storeUsersInfile( @@userStorePath , "page_"+ "#{page}" , userArr )
                self.storeListingLastAct( endCursor, page )
                    
                sleep(2)
                endCursor = endCursor[0..endCursor.length-3]
                ap "endCursor" + "#{endCursor}"
                self.listingFollowersByAPI( queryHash, endCursor, page + 1 )
            else
                ap "finished" 
            end
        rescue
            ap "get soft banned sleep 200 seconds"
            sleep(200)
            self.listingFollowersByAPI( queryHash, endCursor, page )
        end
    end
end
