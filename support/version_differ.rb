class VersionDiffer
  def print_latest(io = $stdout)
    io.puts diff(last_version, '.')
  end

  def update(path)
    old = File.read(path)
    File.open(path, 'w') do |file|
      print_latest(file)
      file << old
    end
  end

  def generate(path)
    versions = released_versions
    versions.unshift '.'

    versions.each_cons(2) do |new_version, old_version|
      File.open(path, 'a') do |file|
        file << diff(old_version, new_version)
      end
    end
  end

  private

  def last_version
    released_versions.first
  end

  def released_versions
    require 'open-uri'
    require 'multi_json'

    versions = MultiJson.decode(open('https://rubygems.org/api/v1/versions/watir.json').read)
    versions.map! { |e| e.fetch('number') }
  end

  def diff(old_version, new_version)
    puts "diffing #{old_version} -> #{new_version}"

    left = "watir-#{old_version}.gem"
    right = new_version == '.' ? new_version : "watir-#{new_version}.gem"

    str = StringIO.new
    str.puts new_version.to_s
    str.puts '=' * new_version.length
    str.puts

    # requires YARD > 0.8.2.1 (i.e. next release at the time of writing)
    query = '!@private && @api.text != "private" && object.visibility == :public'
    content = `yard diff --all --query #{query} #{left} #{right} 2>&1`
    str.puts(content.split("\n").map { |line| line.empty? ? line : "   #{line}" })
    str.puts "\n\n"

    str.string
  end
end
