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

geotex = {}

$stderr.puts "Parsing TM geotex..."
CSV.foreach(File.join(tm_dir, "geotex.csv"), :headers => false) do |row|
  geotex[row[0]] = row
end

$stderr.puts geotex.length

graph = RDF::Graph.new

geotex.each do |geotex_reference|
  tm_geo_id = geotex_reference[1][2].strip
  tm_tex_id = geotex_reference[1][1].strip
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