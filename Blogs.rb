require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'logger'
require 'date'
require 'Blog'

class Blogs

  private
  def Blogs.marshal(filename, data = nil)
    if data != nil then
      LOG.debug "marshal object to " + filename
      open(filename, "w") { |f| Marshal.dump(data, f) }
    elsif File.exists?(filename)
      LOG.debug "unmarshal object from " + filename
      open(filename) { |f| Marshal.load(f) }
    end
  end

  private
  def Blogs.marshal_destroy(filename)
    LOG.debug "destroy objecy " + filename
    if File.exists?(filename)
      File.delete(filename)
    else
      LOG.debug "File does not exists."
    end
  end

# TODO : add ARGV parameters support

  BLOGS_URL = "http://habrahabr.ru/bloglist/page"
  BLOGS_MIN_INDEX = 50

  MONTHS = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря']
  MAX_DATE = Date.new(2007, 01, 01)

  BLOGS_FILE = "blogs.marshal"

  LOG = Logger.new(STDOUT)

  def Blogs.get_blogs
    current_blogs_page = 1
    @blogs = marshal(BLOGS_FILE, nil)
    if @blogs == nil then
      @blogs = Array.new
      while (true)
        doc = Hpricot(open(BLOGS_URL + current_blogs_page.to_s))
        LOG.debug "open URL: " + BLOGS_URL + current_blogs_page.to_s
        doc.search(".blog-row").each do |blog|
          @blogs << Blog.new(blog.search(".blog").at('a').inner_html,
                            blog.search(".blog").at('a')[:href],
                            (blog.search(".category").at('a')[:href] rescue nil),
                            blog.search(".rating").inner_html)
          LOG.debug "read blog: " + @blogs.last.to_s + " Rate: " + @blogs.last.index
          @blogs.last.retrieve
          break if @blogs.last.index.to_i <= BLOGS_MIN_INDEX
        end
        break if blogs.last.index.to_i <= BLOGS_MIN_INDEX
        current_blogs_page += 1
      end
      marshal(BLOGS_FILE, @blogs)
    else
      LOG.debug "unmarshaled: " + @blogs.length.to_s + " blog(s)."
    end

    LOG.debug "done get_blogs"
    return @blogs
  end

end