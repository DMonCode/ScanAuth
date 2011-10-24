#!/usr/bin/env ruby
# Author: Daniel Matthis
# E-mail: daniel.matthis@gmail.com
#
# Purpose: Check /var/log/auth.log for the number of different user names that have attempted to log in.

# Need to add usage information when person doesn't supply file name
# current command usage: scanauth.rb <file_name>

# reads argument variable used when running the command to pass file name to the process.
inputfile = ARGV.first
prompt = "> "

puts "File: #{inputfile}"

if not FileTest.exist?("#{inputfile}") then
  puts "You must include the file name after you type the command."
  puts "Example:"
  puts "$ ./main.rb <file_name>"
  exit
end

=begin
#trying to figure out which I like better? If or the while and user prompt...
while not FileTest.exist?("#{inputfile}") do
  puts "You must supply a file name in order for this program to work?"
  puts "What is the filename ?> "
  inputfile = gets.chomp
end
=end

# each AuthData object contains the line entry's from the log file
# class is loaded into the LogFile.logd array.
class AuthData
  attr_accessor :date
  attr_accessor :hostname
  attr_accessor :process
  attr_accessor :entry
  def initialize
    @date = "unknown date"
    @hostname = "unknown hostname"
    @process = "unknown process"
    @entry = "unknown entry"
  end
  def setdate(ndate)
    @date = ndate
  end
  def sethostname(nhostname)
    @hostname = nhostname
  end
  def setprocess(nprocess)
    @process = nprocess
  end
  def setentry(nentry)
    @entry = nentry
  end
end

# LogFile is the work horse object. It reads the log file and stores the line objects into logd
# each line is broken up placed int eh AuthData object which is stored in the logd array for recal

class LogFile
  attr_accessor :filename
  attr_accessor :logd
  attr_accessor :prochash
  def initialize
    @filename = "No file"
    @logd = Array.new
    @prochash = Hash.new(0)
  end

  def set_filename(file)
    @filename = file
    puts "Set to: #{@filename}"
  end
  def read_file
    puts "Read file: #{@filename}"
    count = 0
    File.open( "#{@filename}", "r").each { |line|
      @logd[count] = AuthData.new 
      count += 1
      line.chomp!
      puts "#{"%05i" % count} ###############"
      puts "#{line}"
      # Get the date from the start of the string
      date = line[/... \d\d \d\d:\d\d:\d\d/]
      @logd[count-1].setdate(date)
      puts "#DATE: [#{date}]"
      # Remove Date from string and get first word for host
      hostname = line.gsub("#{date} ", "")[/\w*/]
      @logd[count-1].sethostname(hostname)
      puts "#HOST: #{hostname}"
      # Get Process
      process = line.gsub("#{date} #{hostname} ", "")[/^.*?:/]
      @logd[count-1].setprocess(process)
      # Get hash count of each process.
      # Future note: Probably should do the same for users when I get to breaking it out.     
      @prochash["#{process}"] += 1
      puts "#PROCESS: #{process}"
      # Remove date and hostname from string.
      entry = line.gsub("#{date} #{hostname} #{process}","")
      @logd[count-1].setentry(entry)
      puts "#ENTRY: #{entry}"
    }    
  end
  def find process
  end
end
obj = LogFile.new
obj.set_filename(inputfile)
obj.read_file

# Quick little report of what is stored in Object 20. Need to add further command line switches to tailor report.

puts "#########################################"
puts "There are #{obj.logd.length} entries"
puts "== Entry 20 =="
puts "Date: #{obj.logd[20].date}"
puts "Host: #{obj.logd[20].hostname}"
puts "Process: #{obj.logd[20].process}"
puts "Entry: #{obj.logd[20].entry}"
puts "#########################################"
puts "How many different processes logged in #{inputfile}? #{obj.prochash.length}"
