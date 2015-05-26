# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Image" do

  before :each do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  # Exists method
  describe "#exists?" do
    it "returns true when the image exists" do
      expect(browser.image(id: 'square')).to exist
      expect(browser.image(id: /square/)).to exist

      not_compliant_on :watir_classic do
        expect(browser.image(src: 'images/circle.png')).to exist
      end

      deviates_on :watir_classic do
        expect(browser.image(src: %r{images/circle.png})).to exist
      end

      expect(browser.image(src: /circle/)).to exist
      expect(browser.image(alt: 'circle')).to exist
      expect(browser.image(alt: /cir/)).to exist
      expect(browser.image(title: 'Circle')).to exist
    end

    it "returns the first image if given no args" do
      expect(browser.image).to exist
    end

    it "returns false when the image doesn't exist" do
      expect(browser.image(id: 'no_such_id')).to_not exist
      expect(browser.image(id: /no_such_id/)).to_not exist
      expect(browser.image(src: 'no_such_src')).to_not exist
      expect(browser.image(src: /no_such_src/)).to_not exist
      expect(browser.image(alt: 'no_such_alt')).to_not exist
      expect(browser.image(alt: /no_such_alt/)).to_not exist
      expect(browser.image(title: 'no_such_title')).to_not exist
      expect(browser.image(title: /no_such_title/)).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.image(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.image(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods
  describe "#alt" do
    it "returns the alt attribute of the image if the image exists" do
      expect(browser.image(id: 'square').alt).to eq "square"
      expect(browser.image(title: 'Circle').alt).to eq 'circle'
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      expect(browser.image(index: 0).alt).to eq ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(index: 1337).alt }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute of the image if the image exists" do
      expect(browser.image(title: 'Square').id).to eq 'square'
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      expect(browser.image(index: 0).id).to eq ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#src" do
    it "returns the src attribute of the image if the image exists" do
      expect(browser.image(id: 'square').src).to include("square.png")
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      expect(browser.image(index: 0).src).to eq ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(index: 1337).src }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute of the image if the image exists" do
      expect(browser.image(id: 'square').title).to eq 'Square'
    end

    it "returns an empty string if the image exists and the attribute doesn't" do
      expect(browser.image(index: 0).title).to eq ""
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(index: 1337).title }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.image(index: 0)).to respond_to(:class_name)
      expect(browser.image(index: 0)).to respond_to(:id)
      expect(browser.image(index: 0)).to respond_to(:style)
      expect(browser.image(index: 0)).to respond_to(:text)
    end
  end

  # Manipulation methods
  describe "#click" do
    it "raises UnknownObjectException when the image doesn't exist" do
      expect { browser.image(id: 'missing_attribute').click }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.image(class: 'missing_attribute').click }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.image(src: 'missing_attribute').click }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.image(alt: 'missing_attribute').click }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  not_compliant_on :webdriver, :watir_classic do
    not_compliant_on :watir_classic do
      describe "#file_created_date" do
        it "returns the date the image was created as reported by the file system" do
          browser.goto(WatirSpec.url_for("images.html", needs_server: true))
          image = browser.image(index: 1)
          path = "#{File.dirname(__FILE__)}/html#{image.src.gsub(WatirSpec.host, '')}"
          image.file_created_date.to_i.to eq File.mtime(path).to_i
        end
      end
    end

    describe "#file_size" do
      it "returns the file size of the image if the image exists" do
        expect(browser.image(id: 'square').file_size).to eq File.size("#{WatirSpec.files}/images/square.png".sub("file://", ''))
      end
    end
  end

  it "raises UnknownObjectException if the image doesn't exist" do
    expect { browser.image(index: 1337).file_size }.to raise_error(Watir::Exception::UnknownObjectException)
  end

  describe "#height" do
    it "returns the height of the image if the image exists" do
      expect(browser.image(id: 'square').height).to eq 88
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(index: 1337).height }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#width" do
    it "returns the width of the image if the image exists" do
      expect(browser.image(id: 'square').width).to eq 88
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(index: 1337).width }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  # Other
  describe "#loaded?" do
    it "returns true if the image has been loaded" do
      expect(browser.image(title: 'Circle')).to be_loaded
      expect(browser.image(alt: 'circle')).to be_loaded
      expect(browser.image(alt: /circle/)).to be_loaded
    end

    it "returns false if the image has not been loaded" do
      expect(browser.image(id: 'no_such_file')).to_not be_loaded
    end

    it "raises UnknownObjectException if the image doesn't exist" do
      expect { browser.image(id: 'no_such_image').loaded? }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.image(src: 'no_such_image').loaded? }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.image(alt: 'no_such_image').loaded? }.to raise_error(Watir::Exception::UnknownObjectException)
      expect { browser.image(index: 1337).loaded? }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  not_compliant_on :webdriver do
    describe "#save" do
      it "saves the image to a file" do
        file = "#{File.expand_path Dir.pwd}/sample.img.dat"
        begin
          browser.image(index: 1).save(file)
          expect(File.exist?(file)).to be true
        ensure
          File.delete(file) if File.exist?(file)
        end
      end
    end
  end

end
