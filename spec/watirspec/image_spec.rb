# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Image" do

  before :each do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true when the image exists" do
      browser.image(:id, 'square').should exist
      browser.image(:id, /square/).should exist

      not_compliant_on :watir_classic do
        browser.image(:src, 'images/circle.png').should exist
      end

      deviates_on :watir_classic do
        browser.image(:src, %r{images/circle.png}).should exist
      end

      browser.image(:src, /circle/).should exist
      browser.image(:alt, 'circle').should exist
      browser.image(:alt, /cir/).should exist
      browser.image(:title, 'Circle').should exist
    end

    it "returns the first image if given no args" do
      browser.image.should exist
    end

    it "returns false when the image doesn't exist" do
      browser.image(:id, 'no_such_id').should_not exist
      browser.image(:id, /no_such_id/).should_not exist
      browser.image(:src, 'no_such_src').should_not exist
      browser.image(:src, /no_such_src/).should_not exist
      browser.image(:alt, 'no_such_alt').should_not exist
      browser.image(:alt, /no_such_alt/).should_not exist
      browser.image(:title, 'no_such_title').should_not exist
      browser.image(:title, /no_such_title/).should_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      lambda { browser.image(:id, 3.14).exists? }.should raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      lambda { browser.image(:no_such_how, 'some_value').exists? }.should raise_error(MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#alt" do
    it "returns the alt attribute of the image if the image exists" do
      browser.image(:id, 'square').alt.should == "square"
      browser.image(:title, 'Circle').alt.should == 'circle'
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      browser.image(:index, 0).alt.should == ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:index, 1337).alt }.should raise_error(UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute of the image if the image exists" do
      browser.image(:title, 'Square').id.should == 'square'
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      browser.image(:index, 0).id.should == ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:index, 1337).id }.should raise_error(UnknownObjectException)
    end
  end

  describe "#src" do
    it "returns the src attribute of the image if the image exists" do
      browser.image(:id, 'square').src.should include("square.png")
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      browser.image(:index, 0).src.should == ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:index, 1337).src }.should raise_error(UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute of the image if the image exists" do
      browser.image(:id, 'square').title.should == 'Square'
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      browser.image(:index, 0).title.should == ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:index, 1337).title }.should raise_error(UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      browser.image(:index, 0).should respond_to(:class_name)
      browser.image(:index, 0).should respond_to(:id)
      browser.image(:index, 0).should respond_to(:style)
      browser.image(:index, 0).should respond_to(:text)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "raises UnknownObjectException when the image doesn't exist" do
      lambda { browser.image(:id,    'missing_attribute').click }.should raise_error(UnknownObjectException)
      lambda { browser.image(:class, 'missing_attribute').click }.should raise_error(UnknownObjectException)
      lambda { browser.image(:src,   'missing_attribute').click }.should raise_error(UnknownObjectException)
      lambda { browser.image(:alt,   'missing_attribute').click }.should raise_error(UnknownObjectException)
    end
  end

  not_compliant_on :webdriver, :watir_classic do
    not_compliant_on :watir_classic do
      describe "#file_created_date" do
        it "returns the date the image was created as reported by the file system" do
          browser.goto(WatirSpec.url_for("images.html", :needs_server => true))
          image = browser.image(:index, 1)
          path = "#{File.dirname(__FILE__)}/html#{image.src.gsub(WatirSpec.host, '')}"
          image.file_created_date.to_i.should == File.mtime(path).to_i
        end
      end
    end

    describe "#file_size" do
      it "returns the file size of the image if the image exists" do
        browser.image(:id, 'square').file_size.should == File.size("#{WatirSpec.files}/images/square.png".sub("file://", ''))
      end
    end
  end

  it "raises UnknownObjectException if the image doesn't exist" do
    lambda { browser.image(:index, 1337).file_size }.should raise_error(UnknownObjectException)
  end

  describe "#height" do
    it "returns the height of the image if the image exists" do
      browser.image(:id, 'square').height.should == 88
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:index, 1337).height }.should raise_error(UnknownObjectException)
    end
  end

  describe "#width" do
    it "returns the width of the image if the image exists" do
      browser.image(:id, 'square').width.should == 88
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:index, 1337).width }.should raise_error(UnknownObjectException)
    end
  end

  # Other
  describe "#loaded?" do
    it "returns true if the image has been loaded" do
      browser.image(:title, 'Circle').should be_loaded
      browser.image(:alt, 'circle').should be_loaded
      browser.image(:alt, /circle/).should be_loaded
    end

    it "returns false if the image has not been loaded" do
      browser.image(:id, 'no_such_file').should_not be_loaded
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      lambda { browser.image(:id, 'no_such_image').loaded? }.should raise_error(UnknownObjectException)
      lambda { browser.image(:src, 'no_such_image').loaded? }.should raise_error(UnknownObjectException)
      lambda { browser.image(:alt, 'no_such_image').loaded? }.should raise_error(UnknownObjectException)
      lambda { browser.image(:index, 1337).loaded? }.should raise_error(UnknownObjectException)
    end
  end

  not_compliant_on :webdriver do
    describe "#save" do
      it "saves the image to a file" do
        file = "#{File.expand_path Dir.pwd}/sample.img.dat"
        begin
          browser.image(:index, 1).save(file)
          File.exist?(file).should be_true
        ensure
          File.delete(file) if File.exist?(file)
        end
      end
    end
  end

end
