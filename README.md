# ChunkyCSS

Split CSS into chunks by @media.

## Installation

Add this line to your application's Gemfile:

    gem 'chunky_css'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chunky_css

## Usage

```ruby
require 'chunky_css'

splitter = ChunkyCSS.split(css_str)
splitter.media  # e.g ["all", "screen and (max-width: 1000px)"]
splitter.css_for_media("all") # e.g. "body { color:..."

```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
