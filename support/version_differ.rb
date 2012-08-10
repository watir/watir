class VersionDiffer

  def update(path)
    last_version = released_versions.first

    old = File.read(path)
    File.open(path, "w") do |file|
      file << diff(last_version, ".")
      file << old
    end
  end

  def generate(path)
    versions = released_versions
    versions.unshift "."

    versions.each_cons(2) do |new_version, old_version|
      File.open("CHANGES", "a") do |file|
        file << diff(old_version, new_version)
      end
    end
  end

  private

  def released_versions
    require 'open-uri'
    require 'multi_json'

    versions = MultiJson.decode(open("https://rubygems.org/api/v1/versions/watir-webdriver.json").read)
    versions.map! { |e| e.fetch('number')}
  end

  def diff(old_version, new_version)
    puts "diffing #{old_version} -> #{new_version}"

    left = "watir-webdriver-#{old_version}.gem"
    right = new_version == "." ? new_version : "watir-webdriver-#{new_version}.gem"

    str = StringIO.new
    str.puts "#{new_version}"
    str.puts "=" * new_version.length
    str.puts

    # requires YARD > 0.8.2.1 (i.e. next release at the time of writing)
    content = `yard diff --all --query '!@private && @api.text != "private" && object.visibility == :public' #{left} #{right} 2>&1`
    str.puts content.split("\n").map { |line| line.empty? ? line : "   #{line}" }
    str.puts "\n\n"

    str.string
  end

end