#!/Users/nr/.rbenv/shims/ruby

class ChromePacker

	def initialize(params)
		path = params[:path]
		package_name = params[:name]
		skip = params[:not_minimize]

		if package_name.nil?
			puts "Package name must be specified"
			return
		end

		@current_dir = File.expand_path(path)
		@current_dir_name = File.dirname(@current_dir)
		@ext_names = [".js", ".css"]
		@needed_dirs = ["js", "css"]

		chrome 	= "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
		package = "#{@current_dir_name}/#{package_name}"
		pem 	= "#{@current_dir_name}/#{package_name}.pem"

		if check(package, true) === false
			puts "No such package"
			return
		end

		if check(chrome) === false
			puts "Google Chrome not found"
			return
		end

		if check(pem) === false
			puts "Private key not found: #{pem}"
			return
		end

		chrome_cmd 		= chrome.gsub /([ ]+)/, '\ '
		chrome_version 	= IO.popen "#{chrome_cmd} --version"
		chrome_version 	= chrome_version.readlines
		chrome_version 	= chrome_version.join.gsub /([\n]+)/, ""

		puts "# Working directory   : #{@current_dir_name}"
		puts "# Chrome              : #{chrome_version} #{chrome}"
		puts "# Package             : #{package}"
		puts "# Private key         : #{pem}"
		puts "# Mode                : #{(skip) ? 'Skipping minification' : 'With minification'}"
		puts "======================================="
		sleep 3

		unless skip
			puts "## Minification start"
			@needed_dirs.each do |dir|
				puts "## Processing: #{@current_dir}/#{dir}"
				read_dir "#{@current_dir}/#{dir}"
			end
			puts "Minimization done! Packaging extension..."
		end

		command = "sudo #{chrome_cmd} --pack-extension=#{package} --pack-extension-key=#{pem} --no-message-box"
		puts "Packing extension: #{command}"
		command = %x[#{command}]
		puts "Extension created: #{package}.crx"
	end

	def read_dir(dir)
		Dir.entries(dir).each do |entry|
			file_path = "#{dir}/#{entry}"
			is_file = @ext_names.include?(File.extname(file_path))
			if entry.match /^([\.\_]+)/ then next end
			if is_file || File.directory?(file_path)
				minimize(file_path, File.extname(file_path)) if is_file
			end
			if File.directory?(file_path)
				puts "## Processing: #{file_path}"
				read_dir file_path
			end
		end
	end


	def minimize(file, ext)
		puts "## Minimizing file: #{file}"
		file = File.open(file, "r+")
		temp = file.read.gsub /([\n\t\r]+)/im, ""
		file.truncate 0
		file << temp
		file.close
	end

	def check(path, dir=false)
		if dir === true then return File.directory?(path) end
		return File.file?(path)
	end

end

arguments = { :path => Dir.pwd, :name => nil, :not_minimize => false }

ARGV.each do |val|
	arg = val.split "="
	arg_key = arg[0].gsub "--", ""
	arguments[:"#{arg_key}"] = arg[1]
end

ChromePacker.new(arguments)