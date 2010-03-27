require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'logger'
require 'date'

class Blog
  attr_accessor :title, :url, :category, :index, :articles_counter, :readers, :average_evaluation, :average_per_month, :unhabred_counter, :articles

  def initialize(title, url, category, index)
    @articles = Array.new
    @title = title
    @url = url
    @category = if category.nil? then
      "none"
    else
      category
    end
    @index = index
  end

  def to_s
    @title + " (" + (@category rescue nil) + "), Index: " + @index
  end

  def retrieve
    doc = Hpricot(open(@url))
    blog_about = doc.search(".blog-counts").inner_html
    @articles_counter = blog_about.split(' ')[2] rescue nil
    @readers = blog_about.split(' ')[0] rescue nil

    current_blog_page = 1
    while (true)
      if current_blog_page > 1 then
        LOG.debug "\tparse articles URL: " + @url.downcase + "page" + current_blog_page.to_s + "/"
        begin
          doc = Hpricot(open(@url.downcase + "page" + current_blog_page.to_s + "/"))
        rescue
          LOG.error "\tError while processing URL. Next one, please."
          break
        end
      else
        LOG.debug "\tparse articles URL: " + @url
        doc = Hpricot(open(@url))
      end
      doc.search(".hentry ").each do |article|
        next if article.search(".mark").at('a') != nil
        entry_info = article.search(".mark").at('span')[:title]
        @articles << Article.new(entry_info.split(' ')[1],
                                 entry_info.split(' ')[3].gsub(/[^0-9|\s]/, ''),
                                 entry_info.split(' ')[5].gsub(/[^0-9|\s]/, ''),
                                 parse_date(article.search(".published").at('span').inner_html))
        LOG.debug "\t\t parse - " + article.search(".topic").inner_html + " at " + @articles.last.date.to_s +
                " [+" + @articles.last.up_voices + ", -" + @articles.last.down_voices + ", =" + @articles.last.voices_counter + "]"
        break if @articles.last.date <= MAX_DATE
      end
      break if @articles.last.date <= MAX_DATE
      current_blog_page += 1
    end
  end

  def parse_date(date)
    month = MONTHS.index(date.split(' ')[1]) + 1
    month = 0 if month.nil?
    return Date.new(date.split(' ')[2].gsub(/[^0-9|\s]/, '').to_i, month, date.split(' ')[0].gsub(/[^0-9|\s]/, '').to_i)
  end

  # TODO : add article title 
  class Article
    attr_accessor :voices_counter, :up_voices, :down_voices, :date

    def initialize(voices_counter, up_voices, down_voices, date)
      @voices_counter = voices_counter
      @up_voices = up_voices
      @down_voices = down_voices
      @date = date
    end
  end
end