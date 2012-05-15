require "chunky_css/version"
require "strscan"

module ChunkyCSS
  def self.split(css)
    return Splitter.new(css)
  end

  class Splitter
    def initialize(css)
      @buckets = parse(css)
    end

    def media
      @buckets.keys
    end

    def css_for_media(media)
      @buckets[media]
    end

    private

    def parse(css)
      buckets = {}

      scanner = StringScanner.new(css)

      current_bucket = "all"
      indent = 0
      inside_media = false

      while !scanner.eos? do
        if scanner.scan(/@media (.*?){/)
          current_bucket = scanner[1].chop
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

        buckets[current_bucket] ||= ""
        buckets[current_bucket] += char
      end

      return buckets
    end
  end
end
