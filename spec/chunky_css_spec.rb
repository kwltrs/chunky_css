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
      css.should include("@media screen and (max-width:100px){")
    end
  end
end

describe ChunkyCSS::MediaQuery do
  example "all" do
    mq = ChunkyCSS::MediaQuery.new example.metadata[:description]

    mq.type.should eq("all")
    mq.features.should be_an_instance_of(Hash)
    mq.features.should be_empty
  end

  example "screen and (max-width: 300px)" do
    mq = ChunkyCSS::MediaQuery.new example.metadata[:description]

    mq.type.should eq("screen")
    mq.features.keys.length.should eq(1)
    mq.features.keys.should include("max-width")
    mq.features["max-width"].should eq("300px")
  end

  example "print and (max-width: 400px) and (min-width: 200px)" do
    mq = ChunkyCSS::MediaQuery.new example.metadata[:description]

    mq.type.should eq("print")
    mq.features.keys.length.should eq(2)
    mq.features["min-width"].should eq("200px")
    mq.features["max-width"].should eq("400px")
  end

  example "screen and (width: 100px) and (min-width: 5px) and (max-width: 123456px)" do
    mq = ChunkyCSS::MediaQuery.new example.metadata[:description]

    mq.type.should eq("screen")
    mq.features.keys.length.should eq(3)
    mq.features["width"].should eq("100px")
    mq.features["min-width"].should eq("5px")
    mq.features["max-width"].should eq("123456px")
  end

  example "    screen and (width:100px)    and  (min-width:   5px)and(max-width : 123456 px)   " do
    mq = ChunkyCSS::MediaQuery.new example.metadata[:description]

    mq.type.should eq("screen")
    mq.features.keys.length.should eq(3)
    mq.features["width"].should eq("100px")
    mq.features["min-width"].should eq("5px")
    mq.features["max-width"].should eq("123456px")
  end
end

describe ChunkyCSS::MediaQuery, "#<=>" do
  example "both screen and different max-width" do
    mq1 = ChunkyCSS::MediaQuery.new "screen and (max-width: 200px)"
    mq2 = ChunkyCSS::MediaQuery.new "screen and (max-width: 300px)"

    (mq1 <=> mq2).should eq(-1)
    (mq2 <=> mq1).should eq(1)

    mq1.should be < mq2
    mq2.should be > mq1
  end

  example "both screen and only one with max-width" do
    mq1 = ChunkyCSS::MediaQuery.new "screen"
    mq2 = ChunkyCSS::MediaQuery.new "screen and (max-width: 300px)"

    (mq1 <=> mq2).should eq(-1)
    (mq2 <=> mq1).should eq(1)

    mq1.should be < mq2
    mq2.should be > mq1
  end

  example "both screen and different min-width" do
    mq1 = ChunkyCSS::MediaQuery.new "screen and (min-width: 300px)"
    mq2 = ChunkyCSS::MediaQuery.new "screen and (min-width: 200px)"

    (mq1 <=> mq2).should eq(-1)
    (mq2 <=> mq1).should eq(1)

    mq1.should be < mq2
    mq2.should be > mq1
  end

  example "both screen and only one with min-width" do
    mq1 = ChunkyCSS::MediaQuery.new "screen"
    mq2 = ChunkyCSS::MediaQuery.new "screen and (min-width: 300px)"

    (mq1 <=> mq2).should eq(-1)
    (mq2 <=> mq1).should eq(1)

    mq1.should be < mq2
    mq2.should be > mq1
  end

  example "both screen, both same max-width and different min-width" do
    mq1 = ChunkyCSS::MediaQuery.new "screen and (max-width:400px) and (min-width: 300px)"
    mq2 = ChunkyCSS::MediaQuery.new "screen and (max-width:400px) and (min-width: 200px)"

    (mq1 <=> mq2).should eq(-1)
    (mq2 <=> mq1).should eq(1)

    mq1.should be < mq2
    mq2.should be > mq1
  end

  example "both screen, both same max-width and only one with min-width" do
    mq1 = ChunkyCSS::MediaQuery.new "screen and (max-width:400px)"
    mq2 = ChunkyCSS::MediaQuery.new "screen and (max-width:400px) and (min-width: 300px)"

    (mq1 <=> mq2).should eq(-1)
    (mq2 <=> mq1).should eq(1)

    mq1.should be < mq2
    mq2.should be > mq1
  end
end

describe ChunkyCSS::MediaQuery, "media_description" do
  ["all", "screen", "screen and (max-width:400px)", "screen and (max-width:300px) and (min-width:200px)"].each do |query|
    example query do
      mq = ChunkyCSS::MediaQuery.new( example.metadata[:description] )
      mq.media_description.should eq( example.metadata[:description] )
    end
  end
end

describe ChunkyCSS::MediaQuery, "#to_css" do
  example "media all with some rules" do
    mq = ChunkyCSS::MediaQuery.new "all"
    mq.css_rules = "body{color:red;}"

    mq.to_css.should eq("body{color:red;}")
  end

  example "media screen with some rules" do
    mq = ChunkyCSS::MediaQuery.new "screen"
    mq.css_rules = "body{color:red;}"
    mq.to_css.should eq("@media screen{body{color:red;}}")
  end

  example "media screen and max-width with some rules" do
    mq = ChunkyCSS::MediaQuery.new "screen and (max-width:400px)"
    mq.css_rules = "body{color:red;}"
    mq.to_css.should eq("@media screen and (max-width:400px){body{color:red;}}")
  end
end
