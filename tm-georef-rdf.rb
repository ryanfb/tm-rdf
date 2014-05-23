#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'csv'
require 'rdf/raptor'

tm_prefix = "http://www.trismegistos.org"
# /text/
# /place/
# /name/
# /archive/
# /collection/
# /ref/ e.g. http://www.trismegistos.org/ref/detail.php?ref_id=83996 for name references
# /person/ e.g. www.trismegistos.org/person/48170

tm_dir, output_ttl = ARGV

georef = {}

$stderr.puts "Parsing TM georef..."
CSV.foreach(File.join(tm_dir, "georef.csv"), :headers => false) do |row|
  georef[row[0]] = row
end

$stderr.puts georef.length

graph = RDF::Graph.new

georef.each do |geo_reference|
  tm_geo_id = geo_reference[1][7].strip
  tm_tex_id = geo_reference[1][5].strip
  if ((!tm_tex_id.nil?) && (!tm_tex_id.empty?))
    $stderr.puts "Inserting relation #{tm_geo_id} -> #{tm_tex_id}"
    graph << RDF::Statement.new(
      RDF::URI.new("#{tm_prefix}/place/#{tm_geo_id}"),
      RDF::DC.relation,
      RDF::URI.new("#{tm_prefix}/text/#{tm_tex_id}"))
  end
end

RDF::Writer.open(output_ttl) do |writer|
  graph.each_statement do |statement|
    writer << statement
  end
end