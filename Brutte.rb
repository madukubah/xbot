require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require 'watir-scroll'
require 'net/http'
require 'uri'
require 'json'
require 'mysql2' #database

# a = 65+25
# puts a.chr

# puts /[A-Z,\d][A-Z,\d][A-Z,\d][A-Z,\d][A-Z,\d]/.to_s
array = array.grep /[A-Z,\d][A-Z,\d][A-Z,\d][A-Z,\d][A-Z,\d]/
array.each do |row|
end

# puts %w[/like/].permutation.map &:join


# begin
#     a = 64
#     puts a.chr
#     p1 = a
#     p2 = a
#     p3 = a
#     p4 = a
#     p5 = a
#     p6 = a

#     begin
#         # puts p1.chr+p2.chr+p3.chr+p4.chr+p5.chr+p6.chr
#         begin
#             p1 +=1
#             begin
#                 p2 +=1
#                 begin
#                     p3 +=1
#                     begin
#                         p4 +=1
#                         begin
#                             p5 +=1
#                             begin
#                                 p6 +=1
#                                 if p6.chr == 'Z'
#                                     break
#                                 end
#                                 puts p1.chr+p2.chr+p3.chr+p4.chr+p5.chr+p6.chr
#                             end until false
#                         end until false
#                     end until false
#                 end until false
#             end until false
#         end until false
#     end until false
# end until false
