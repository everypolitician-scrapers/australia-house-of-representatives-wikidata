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

def wikinames_from(url)
  noko = noko_for(url)
  names = noko.xpath('//table[.//th[contains(., "Electorate")]]//tr[td]//td[1]//a[not(@class="new")]/@title').map(&:text)
  raise "No names found in #{url}" if names.count.zero?
  return names
end

def fetch_info(names)
  WikiData.ids_from_pages('en', names.flatten.compact.uniq).each do |name, id|
    data = WikiData::Fetcher.new(id: id).data rescue nil
    unless data
      warn "No data for #{p}"
      next
    end
    data[:original_wikiname] = name
    ScraperWiki.save_sqlite([:id], data)
  end
end

urls = [
  'Members_of_the_Australian_House_of_Representatives,_2013–2016',
  'Members_of_the_Australian_House_of_Representatives,_2010–2013',
  'Members_of_the_Australian_House_of_Representatives,_2007–2010',
  'Members_of_the_Australian_House_of_Representatives,_2004–2007',
  'Members_of_the_Australian_House_of_Representatives,_2001–2004',
  'Members_of_the_Australian_House_of_Representatives,_1998–2001',
  'Members_of_the_Australian_House_of_Representatives,_1996–1998',
  'Members_of_the_Australian_House_of_Representatives,_1993–1996',
  'Members_of_the_Australian_House_of_Representatives,_1990–1993',
  'Members_of_the_Australian_House_of_Representatives,_1987–1990',
]


fetch_info(
  urls.map { |u| wikinames_from('https://en.wikipedia.org/wiki/' + URI.encode(u)) }.reduce(&:+)
)

require 'rest-client'
warn RestClient.post ENV['MORPH_REBUILDER_URL'], {} if ENV['MORPH_REBUILDER_URL']
