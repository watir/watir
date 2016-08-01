# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "FileField" do

  before :each do
    browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
  end

  describe "#exist?" do
    it "returns true if the file field exists" do
      expect(browser.file_field(id: 'new_user_portrait')).to exist
      expect(browser.file_field(id: /new_user_portrait/)).to exist
      expect(browser.file_field(name: 'new_user_portrait')).to exist
      expect(browser.file_field(name: /new_user_portrait/)).to exist
      expect(browser.file_field(class: 'portrait')).to exist
      expect(browser.file_field(class: /portrait/)).to exist
      expect(browser.file_field(index: 0)).to exist
      expect(browser.file_field(xpath: "//input[@id='new_user_portrait']")).to exist
    end

    it "returns the first file field if given no args" do
      expect(browser.file_field).to exist
    end

    it "returns true for element with upper case type" do
      expect(browser.file_field(id: "new_user_resume")).to exist
    end

    it "returns false if the file field doesn't exist" do
      expect(browser.file_field(id: 'no_such_id')).to_not exist
      expect(browser.file_field(id: /no_such_id/)).to_not exist
      expect(browser.file_field(name: 'no_such_name')).to_not exist
      expect(browser.file_field(name: /no_such_name/)).to_not exist
      expect(browser.file_field(class: 'no_such_class')).to_not exist
      expect(browser.file_field(class: /no_such_class/)).to_not exist
      expect(browser.file_field(index: 1337)).to_not exist
      expect(browser.file_field(xpath: "//input[@id='no_such_id']")).to_not exist
    end

    it "raises TypeError when 'what' argument is invalid" do
      expect { browser.file_field(id: 3.14).exists? }.to raise_error(TypeError)
    end

    it "raises MissingWayOfFindingObjectException when 'how' argument is invalid" do
      expect { browser.file_field(no_such_how: 'some_value').exists? }.to raise_error(Watir::Exception::MissingWayOfFindingObjectException)
    end
  end

  # Attribute methods

  describe "#class_name" do
    it "returns the class attribute if the text field exists" do
      expect(browser.file_field(index: 0).class_name).to eq "portrait"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.file_field(index: 1337).class_name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#id" do
    it "returns the id attribute if the text field exists" do
      expect(browser.file_field(index: 0).id).to eq "new_user_portrait"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.file_field(index: 1337).id }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#name" do
    it "returns the name attribute if the text field exists" do
      expect(browser.file_field(index: 0).name).to eq "new_user_portrait"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.file_field(index: 1337).name }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#title" do
    it "returns the title attribute if the text field exists" do
      expect(browser.file_field(id: "new_user_portrait").title).to eq "Smile!"
    end
  end

  describe "#type" do
    it "returns the type attribute if the text field exists" do
      expect(browser.file_field(index: 0).type).to eq "file"
    end

    it "raises UnknownObjectException if the text field doesn't exist" do
      expect { browser.file_field(index: 1337).type }.to raise_error(Watir::Exception::UnknownObjectException)
    end
  end

  describe "#respond_to?" do
    it "returns true for all attribute methods" do
      expect(browser.file_field(index: 0)).to respond_to(:class_name)
      expect(browser.file_field(index: 0)).to respond_to(:id)
      expect(browser.file_field(index: 0)).to respond_to(:name)
      expect(browser.file_field(index: 0)).to respond_to(:title)
      expect(browser.file_field(index: 0)).to respond_to(:type)
      expect(browser.file_field(index: 0)).to respond_to(:value)
    end
  end

  # Manipulation methods

  describe "#set" do
    not_compliant_on :iphone, :safari do
      bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1260233", :firefox do
        bug "https://github.com/detro/ghostdriver/issues/183", :phantomjs do
          it "is able to set a file path in the field and click the upload button and fire the onchange event" do
            browser.goto WatirSpec.url_for("forms_with_input_elements.html")

            path    = File.expand_path(__FILE__)
            element = browser.file_field(name: "new_user_portrait")

            element.set path

            expect(element.value).to include(File.basename(path)) # only some browser will return the full path
            expect(messages.first).to include(File.basename(path))

            browser.button(name: "new_user_submit").click
          end
        end

        it "raises an error if the file does not exist" do
          expect {
            browser.file_field.set(File.join(Dir.tmpdir, 'unlikely-to-exist'))
          }.to raise_error(Errno::ENOENT)
        end
      end
    end
  end


  bug "https://github.com/detro/ghostdriver/issues/183", :phantomjs do
    not_compliant_on :iphone, :safari do
      bug "https://bugzilla.mozilla.org/show_bug.cgi?id=1260233", :firefox do
        describe "#value=" do
          it "is able to set a file path in the field and click the upload button and fire the onchange event" do
            browser.goto WatirSpec.url_for("forms_with_input_elements.html")

            path    = File.expand_path(__FILE__)
            element = browser.file_field(name: "new_user_portrait")

            element.value = path
            expect(element.value).to include(File.basename(path)) # only some browser will return the full path
          end

          not_compliant_on :internet_explorer do
            it "does not raise an error if the file does not exist" do
              path = File.join(Dir.tmpdir, 'unlikely-to-exist')
              browser.file_field.value = path

              expected = path
              expected.gsub!("/", "\\") if WatirSpec.platform == :windows

              expect(browser.file_field.value).to include(File.basename(expected)) # only some browser will return the full path
            end

            it "does not alter its argument" do
              value = '/foo/bar'
              browser.file_field.value = value
              expect(value).to eq '/foo/bar'
            end
          end
        end
      end
    end
  end

end
