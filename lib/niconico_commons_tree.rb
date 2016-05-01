require 'niconico_commons_tree/version'
require 'open-uri'
require 'nokogiri'

module NiconicoCommonsTree
  class Node
    SERVER_URL = 'http://commons.nicovideo.jp/tree'

    def initialize(ident, page_file = nil)
      @page_file = page_file || open("#{SERVER_URL}/#{ident}")
    end

    def id
      @id || @id = now_box.attribute('id').value
    end

    def thumb
      @thumb || @thumb = now_box.xpath('div[@class="thum"]')
                                .xpath('a/img')
                                .attribute('src').value
    end

    def name
      @name || @name = now_box.xpath('div[@class="dsc"]/a').inner_text
    end

    def children
      @children || @children = child_ids.map { |child_id| p self.class.new child_id }
    end

    def parents
      @parents || @parents = parent_ids.map { |parent_id| p self.class.new parent_id }
    end

    private
    def page
      @page || @page = Nokogiri::HTML.parse(@page_file)
    end

    def now_box
      @now_box || @now_box = page.xpath('//div[@id="NowBox"]')
                                 .xpath('div[contains(@class,"item-list")]/ul/li').first
    end

    def parent_box
      @parent_box || @parent_box = page.xpath('//div[@id="ParentBox"]')
                                       .xpath('div[contains(@class,"item-list")]/ul/li')
    end

    def child_box
      @child_box || @child_box = page.xpath('//div[@id="ChildBox"]')
                                     .xpath('div[contains(@class,"item-list")]/ul/li')
    end

    def parent_ids
      @parent_ids || @parent_ids = parent_box.map do |parent|
                                     parent.xpath('a[@class="title_link"]')
                                           .attribute('href')
                                           .value
                                           .match(/http:\/\/www\.nicovideo\.jp\/watch\/(.+)/)[1]
                                   end
    end

    def child_ids
      @child_ids || @child_ids = child_box.map do |child|
                                   child.xpath('a[@class="title_link"]')
                                        .attribute('href')
                                        .value
                                        .match(/http:\/\/www\.nicovideo\.jp\/watch\/(.+)/)[1]
                                 end
    end
  end
end
