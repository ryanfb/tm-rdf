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

tex = {}

$stderr.puts "Parsing TM tex..."
CSV.foreach(File.join(tm_dir, "tex.csv"), :headers => false) do |row|
  tex[row[0]] = row
end

$stderr.puts tex.length

graph = RDF::Graph.new

tex.each do |text|
  tm_id = text[0]
  tm_reuse_string = text[1][14]
  if ((!tm_reuse_string.nil?) && (!tm_reuse_string.empty?))
    all_reuses = tm_reuse_string.split(",").map{|i| i.strip}
    all_reuses.each do |reuse_tm_id|
      $stderr.puts "Inserting reuse #{tm_id} -> #{reuse_tm_id}"
      graph << RDF::Statement.new(
        RDF::URI.new("#{text_url_prefix}/text/#{tm_id}"),
        RDF::DC.relation,
        RDF::URI.new("#{text_url_prefix}/text/#{reuse_tm_id}"))
    end
  end
end

RDF::Writer.open(output_ttl) do |writer|
  graph.each_statement do |statement|
    writer << statement
  end
end