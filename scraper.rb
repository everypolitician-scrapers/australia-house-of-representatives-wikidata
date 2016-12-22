#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'
require 'pry'

urls = [
  'Members_of_the_Australian_House_of_Representatives,_2016–2019',
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

names = urls.map do |url|
  EveryPolitician::Wikidata.wikipedia_xpath(
    url: "https://en.wikipedia.org/wiki/#{url}",
    xpath: '//table[.//th[contains(., "Electorate")]]//tr[td]//td[1]//a[not(@class="new")]/@title',
  )
end.flatten.compact.uniq

EveryPolitician::Wikidata.scrape_wikidata(names: { en: names })
