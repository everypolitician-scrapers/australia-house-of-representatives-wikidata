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
  noko.xpath('//table[.//th[contains(., "Electorate")]]//tr[td]//td[1]//a[not(@class="new")]/@title').map(&:text)
end

def fetch_info(names)
  WikiData.ids_from_pages('en', names.compact.uniq).each do |name, id|
    data = WikiData::Fetcher.new(id: id).data rescue nil
    unless data
      warn "No data for #{p}"
      next
    end
    data[:original_wikiname] = name
    warn data
    ScraperWiki.save_sqlite([:id], data)
  end
end

names = wikinames_from('https://en.wikipedia.org/wiki/Members_of_the_Australian_House_of_Representatives,_2013%E2%80%932016')
abort "No names" if names.count.zero?

fetch_info(names)

