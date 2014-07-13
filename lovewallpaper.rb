#!/usr/bin/env ruby

# Version: 0.1b
# See LICENSE for details

require 'fileutils'
require 'digest'
require 'rexml/document'

# file created by Ubuntu Tweak
ORIGINAL_FILE = "/home/#{ENV['SUDO_USER']}/.config/ubuntu-tweak/lovewallpaper.jpg"
COPY_FILE = "/usr/share/backgrounds/#{Digest::SHA1.hexdigest (Time.now.to_s)}.jpg"
THEME_FILE = "/usr/share/backgrounds/contest/lovewallpaper.xml"
puts ORIGINAL_FILE
# XML template for live wallpaper file
INITIAL_XML = 
%Q{\
<background>
  <starttime>
    <year>#{Time.now.year}</year>
    <month>#{Time.now.month}</month>
    <day>#{Time.now.day}</day>
    <hour>00</hour>
    <minute>00</minute>
    <second>00</second>
  </starttime>
  <static>
    <duration>1795.0</duration>
    <file>#{COPY_FILE}</file>
  </static>
  <transition>
    <duration>5.0</duration>
    <from>#{COPY_FILE}</from>
    <to>#{COPY_FILE}</to>
  </transition>
</background>
}

# duration for animation
STATIC_DURATION = "600.0"
DYNAMIC_DURATION = "5.0"

FileUtils.cp ORIGINAL_FILE, COPY_FILE

def add_lovewallpaper
	if !FileTest.exist? (THEME_FILE)
		File.open( THEME_FILE, "w+") do |file|
			file.write (INITIAL_XML)
		end
	else
		include REXML
		File.open(THEME_FILE, "r+") do |file|
			doc = Document.new (file)
			root = doc.root
			first_static = root.elements.to_a("static").first
			last_transition = root.elements.to_a("transition").last

			last_transition.elements["to"].text = COPY_FILE

			static = root.add_element "static"
			static.add_element("duration").text = STATIC_DURATION
			static.add_element("file").text = COPY_FILE

			transition = root.add_element "transition"
			transition.add_element("duration").text = DYNAMIC_DURATION
			transition.add_element("from").text = COPY_FILE
			transition.add_element("to").text = first_static.elements["file"].text

			file.rewind
			# format with 2 tabs indents
			formatter = REXML::Formatters::Pretty.new(2)
			formatter.compact = true
			formatter.write(doc, file)
		end
	end
end

if $0 == __FILE__
	add_lovewallpaper
end
