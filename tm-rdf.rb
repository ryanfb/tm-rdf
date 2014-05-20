#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'csv'

tm_dir = ARGV

tex = {}

$stderr.puts "Parsing TM tex..."
CSV.foreach(File.join(tm_dir, "tex.csv"), :headers => false) do |row|
  tex[row[0]] = row
end

$stderr.puts tex.length