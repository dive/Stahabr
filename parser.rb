require 'rubygems'
require 'Blogs'

def raiting(all_blogs)
  blogs = all_blogs[0..19]
  # by rating
  puts "by rating:"
  blogs.each {|blog| puts blog.title + "\t" + blog.index}

  # by articles
  puts "\nby articles length:"
  blogs.sort! {|a, b| b.articles.length <=> a.articles.length}
  blogs.each {|blog| puts blog.title + "\t" + blog.articles.length.to_s}

  #by readers
  puts "\nby readers:"
  blogs.sort! {|a, b| b.readers.to_i <=> a.readers.to_i}
  blogs.each {|blog| puts blog.title + "\t" + blog.readers.to_s}

  #by average evaluation
  puts "\nby average evaluation:"
  blogs.each{|blog| blog.average_evaluation = 0 if blog.average_evaluation.nil?}
  blogs.each{|blog| temp_evaluation = 0; blog.articles.each {|article| blog.average_evaluation = (temp_evaluation += article.voices_counter.to_i) / blog.articles.length}}
  blogs.sort! {|a, b| b.average_evaluation.to_i <=> a.average_evaluation.to_i}
  blogs.each{|blog| puts blog.title + "\t" + blog.average_evaluation.to_s}
end

def categories_raiting(all_blogs)
  categories = Hash.new
  all_blogs.each{|blog|
    if categories[blog.category].nil? then
      categories[blog.category] = 1
    else
      categories[blog.category] += 1
    end}
  categories = categories.sort {|a, b| b[1] <=> a[1]}
  categories.each{|key, value| puts key + "\t" + value.to_s}
end

def trends(all_blogs)
  date = Date.new(2007, 01, 01)
  dates = Array.new
  dates << date
  current_month = date.month
  while (true) do
    date = date.next
    next if current_month == date.month
    current_month = date.month
    dates << date
    puts dates.last
    break if date.year == 2010 and date.month == 3
  end

  all_blogs.each {|blog|
    puts blog.title
    by_month = Hash[*dates.zip([0] * dates.size).flatten]
    blog.articles.each {|article|
      date = Date.new(article.date.year, article.date.month, 1)
      next if date.year <= 2007
      by_month[date] += 1
    }
    by_month = by_month.sort
#    by_month.each {|key, value| puts key.to_s + "\t" + value.to_s}
    by_month.each {|key, value| puts value.to_s}
  }
end

def articles_per_month(all_blogs)
  by_month = Hash.new
  all_blogs.each { |blog|
    blog.articles.each { |article|
      date = Date.new(article.date.year, article.date.month, 1)
      if by_month[date].nil? then
        by_month[date] = 1
      else
        by_month[date] += 1
      end
    }
  }
  by_month.sort.each {|key, value| puts key.to_s + "\t" + value.to_s}
end

blogs = Blogs.get_blogs

#raiting blogs
#categories_raiting blogs
#trends blogs
articles_per_month blogs