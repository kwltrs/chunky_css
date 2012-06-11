require "strscan"

module ChunkyCSS
  def self.split(css)
    Splitter.new(css)
  end

  def self.group(css)
    Grouper.new(css).grouped_css
  end


  module Parser
    def parse(css)
      buckets = {}

      scanner = StringScanner.new(css)

      current_bucket = "all"
      indent = 0
      inside_media = false

      while !scanner.eos? do
        if scanner.scan(/@media (.*?){/)
          current_bucket = scanner[1].strip
          indent += 1
          inside_media = true
        end

        char = scanner.getch

        if char == "{"
          indent += 1
        elsif char == "}"
          indent -= 1
          if indent == 0 && inside_media
            inside_media = false
            current_bucket = "all"
            char = ""
          end 
        end

        buckets[current_bucket] ||= MediaQuery.new(current_bucket)
        buckets[current_bucket].css_rules += char
      end

      return buckets
    end
  end

  class Splitter
    include Parser

    def initialize(css)
      @buckets = parse(css)
    end

    def media
      @buckets.keys
    end

    def css_for_media(media)
      (@buckets.has_key? media) ? @buckets[media].css_rules : nil
    end
  end

  class Grouper < Splitter
    def grouped_css
      @buckets.values.sort.map{|mq| mq.to_css }.join("\n")
    end
  end


  module RegEx
    TYPE = /(all|screen|print)/
    FEATURE_WITH_LENGTH = /\((((min|max)-)?width\s*:\s*\d+\s*px)\)/
  end

  class MediaQuery
    include Comparable 

    attr_reader :type
    attr_reader :features
    attr_accessor :css_rules

    def initialize(querystr)
      @features = {}
      @type = "all"
      @css_rules = ""

      scanner = StringScanner.new(querystr)

      while !scanner.eos? do
        if scanner.scan RegEx::TYPE
          @type = scanner[1]
        elsif scanner.scan RegEx::FEATURE_WITH_LENGTH
          (key, value) = scanner[1].split(/\s*:\s*/)
          @features[key] = value.gsub(/\s/, '')
        else
          scanner.getch
        end
      end
    end

    def <=>(other)
      d = @features["max-width"].to_i <=> other.features["max-width"].to_i

      if (d == 0)
        my_min_width, other_min_width = [@features, other.features].map{|f| f["min-width"].to_i}

        d = other_min_width <=> my_min_width
        d *= -1  if [my_min_width, other_min_width].include?(0)
      end

      d
    end

    def media_description
      [ @type ].concat( @features.keys.map {|key|
        "(%s:%s)"%[key, @features[key]]
      } ).join(" and ")
    end

    def to_css
      if @type == "all" && @features.empty?
        @css_rules
      else
        "@media %s{%s}"%[media_description, @css_rules]
      end
    end
  end
end
