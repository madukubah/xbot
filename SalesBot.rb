require 'json'
require_relative 'Bot' 
require 'fileutils'
require 'pg'
require 'awesome_print' # Console output

require 'optparse'
require 'ostruct'

class SalesBot < Bot
    @@conn
    @@class 
    @@message 
    def initialize( params = {} )
        super
        dbname = params.fetch( :dbname,'instanalitic' )
        ap "use dbname %s" % [dbname]
        @@conn = PG.connect :dbname => dbname , :user => 'madukubah', :password => 'Alan!234'
        rs  = @@conn.exec('SELECT * from bots limit 1')
        rs.each do |row|
            @@class = row['class_code']
            @@message = row['message']
        end
    end

    def do_message( username )
        self.visitUser( username )
        self.followUser( username )
        if @@browser.button(:class => [ 'sqdOP', 'L3NKy', '_4pI4F', '_8A5w5'] ).exists?
            @@browser.button(:class => [ 'sqdOP', 'L3NKy', '_4pI4F', '_8A5w5'] ).click
            sleep(4)

            if @@browser.div(:class => ['Igw0E', 'IwRSH', 'eGOV_', 'vwCYk', 'ItkAi'] ).exists?
                messageElem = @@browser.div(:class => ['Igw0E', 'IwRSH', 'eGOV_', 'vwCYk', 'ItkAi'] )
                messageElem.textarea().set "%s" % [ @@message ]
                sleep(2)
                messageElem.textarea().send_keys(:enter)
            end
        end
    end

    def ask_for_dm( username )
        self.visitUser( username )
        if @@browser.div(class:"eLAPa").exists?
            @@browser.div(class:"eLAPa").click
            sleep(1)
            if @@browser.textarea(class:"Ypffh").exists?
                @@browser.textarea(class:"Ypffh").set "cek dm"
                @@browser.form(class:"X7cDz").submit
            end
        end
    end

    def do_advertising( )
        rs  = @@conn.exec('SELECT * from account_analysis where code=%s' % [ @@class ] )
        rs.each do |row|
            puts "%s " % [ row['username'] ]
            # do_message( "_madukubah" )
            do_message( row['username'] )
            # ask_for_dm( "mildafatriani" )
        end
    end

end

# START ================================

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on( '--db DATABASE', 'The Database Used') { |o| options.db = o }
end.parse!

salesBot = SalesBot.new(
    :dbname => options.db
 )
salesBot.login( 'alan_12213', 'Alan!234' )
salesBot.do_advertising( )

sleep(500)