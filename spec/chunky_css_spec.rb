require "chunky_css"

def fixture(fname)
  File.read( File.join(File.dirname(__FILE__), "fixtures", fname) )
end

describe ChunkyCSS::Splitter do
  %w(simple.css simple-compressed.css).each do |css_file|
    context css_file do
      splitter = ChunkyCSS::Splitter.new(fixture(css_file))

      it "has 3 media queries" do
        splitter.media.length.should eq(3)
      end

      expectations = {
        "all" => [1,2,7],
        "screen" => [3,4],
        "screen and (max-width: 100px)" => [5,6]
      }
      
      expectations.keys.each do |media|
        it "has a '#{media}' entry" do
          splitter.media.should include(media)
        end

        context "css for @media '#{media}'" do
          css = splitter.css_for_media(media)

          expectations[media].each do |rule_number|
            it "contains css rule for .rule#{rule_number}" do
              css.should include(".rule#{rule_number}")
            end
          end
        end
      end
    end
  end
end

describe ChunkyCSS::Grouper do
  context "simple-compressed.css" do
    grouper = ChunkyCSS::Grouper.new(fixture("simple-compressed.css"))
    css = grouper.grouped_css

    it "starts with global rules without @media" do
      css.should start_with(".rule1{color: red;}.rule2{color: red;}.rule7{color: red;}")
    end

    it "has a 'screen' entry" do
      css.should include("@media screen{")
    end

    it "has a 'screen and max-width' entry" do
      css.should include("@media screen and (max-width: 100px){")
    end
  end
end
