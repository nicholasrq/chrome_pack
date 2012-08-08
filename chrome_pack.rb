#!/usr/bin/ruby

## Chrome Pack v1.0.1
## Author: Nicholas R, 2012

require 'fileutils'

class ChromePacker

	def initialize(params)
		path = params[:path] || params[:p]
		package_name = params[:name] || params[:n]
		skip = params[:not_minimize] || params[:nm]
		type = params[:type] || params[:t]

		if package_name.nil?
			puts "Package name must be specified"
			return
		end

		@current_dir = File.expand_path(path)
		@current_dir_name = File.dirname(@current_dir)
		@ext_names = [".js", ".css"]
		@needed_dirs = ["js", "css"]
		@exclude = ["libs"]
		@compiler = "#{File.dirname(__FILE__)}/compiler.jar"

		chrome 	= "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
		package = "#{@current_dir_name}/#{package_name}"
		pem 	= "#{@current_dir_name}/#{package_name}.pem"

		if check(@compiler) === false
			puts "Compiler not found"
			return
		end

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
		command = nil
		case type
			when "crx":
				puts "Creating chrome extension *.crx file"
				command = "sudo #{chrome_cmd} --pack-extension=#{package} --pack-extension-key=#{pem} --no-message-box"
			when "zip":
				puts "Zipping chrome extension into #{@current_dir_name}/#{package_name}.zip"
				command = "zip -r #{@current_dir_name}/#{package_name}.zip #{package}"
			else return puts "Type is unavailable" unless command
		end

		command = %x[#{command}]
	end

	def read_dir(dir)
		Dir.entries(dir).each do |entry|
			file_path = "#{dir}/#{entry}"
			is_file = @ext_names.include?(File.extname(file_path))
			if entry.match /^([\.\_]+)/ then next end
			if is_file
				minimize(file_path, File.extname(file_path)) if is_file
			elsif File.directory?(file_path) && @exclude.include?(entry) == false
				puts "## Processing: #{file_path}"
				read_dir file_path
			else
				puts "Skipping #{entry}"
			end
		end
	end


	def minimize(file, ext)
		case(ext)
			when ".js":
				puts "## Minimizing javascript using Google CC: #{file}"
				cmd = "sudo java -jar #{@compiler} --js #{file} --js_output_file #{file}-temp"
				%x[#{cmd}]
				temp = File.open("#{file}-temp", "r")
				newfile = File.open(file, "w+")
				newfile << temp.read.to_s
				newfile.close
				temp.close
				FileUtils.rm("#{file}-temp")
			else
				puts "## Minimizing file: #{file}"
				f = File.open(file, "rb")
				temp = f.read.to_s.gsub /([\n\t\r]+)/im, ""
				f.close

				f = File.open(file, "w+")
				f << temp
				f.close
		end
	end

	def check(path, dir=false)
		if dir === true then return File.directory?(path) end
		return File.file?(path)
	end

end

arguments = {}
arguments.update({ :path => nil, :name => nil, :not_minimize => nil, :type => nil })
arguments.update({ :p => Dir.pwd, :n => nil, :nm => false, :t => "crx" })

args = ARGV.join(" ").scan(/--?([a-z]+)(\s|=)([\w\d]+)/)

args.each do |argument|
	if argument.kind_of? Array and argument.length > 0
		arguments[:"#{argument[0]}"] = argument[2]
	end
end

ChromePacker.new(arguments)