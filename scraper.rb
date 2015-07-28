#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'wikidata/fetcher'

require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

noko = noko_for('https://en.wikipedia.org/wiki/Members_of_the_Australian_House_of_Representatives,_2013%E2%80%932016')
noko.xpath('.//table[tr[contains(.,"Electorate")]]//tr[td]').each do |tr|
  member = tr.css('td').first.css('a/@title').text
  data = WikiData::Fetcher.new(title: member).data or next
  puts data
  # ScraperWiki.save_sqlite([:id], data)
end

