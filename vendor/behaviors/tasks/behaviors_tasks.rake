
desc "List behavioral definitions for the classes under test (use for=<term> also)"
task :behaviors do
  specifications.each do |spec|
    puts "#{spec.name} should:\n"
		spec.requirements.each do |req|
			puts " - #{req}"
		end
	end
end

desc "List behavioral definitions for the classes under test (HTML output)"
task :behaviors_html do
	require 'erb'
  txt =<<-EOS	
	<html>
	<head>
	  <style>

			div.title
			{
				width: 600px;
				font: bold 14pt trebuchet ms;
			}
				
			div.specification 
			{
				font: bold 12pt trebuchet ms;
				border: solid 1px black;
				width: 600px;
				padding: 5px;
				margin: 5px;
			}

			ul.requirements
			{
				font: normal 11pt verdana;
				padding-left: 0;
				margin-left: 0;
				border-bottom: 1px solid gray;
				width: 600px;
			}

			ul.requirements li
			{
				list-style: none;
			  margin: 0;
			  padding: 0.25em;
			  border-top: 1px solid gray;
			}
	  </style>
	</head>
	<body>
	<div class="title">Specifications for <%= title %></div>
	<% specifications.each do |spec| %>
	  <div class="specification">
		  <%= spec.name %> should: 
			<ul class="requirements">
			  <% spec.requirements.each do |req| %>
					<li><%= req %></li>
				<% end %>
			</ul>
		</div>
	<% end %>
	</body>
	</html>
	EOS
	output = File.expand_path("#{APP_ROOT}/doc/behaviors.html")
	File.open(output,"w") do |f|
		f.write ERB.new(txt).result(binding)
	end
	puts "(Wrote #{output})"
end

def title
	File.basename(File.expand_path(APP_ROOT))
end

def specifications
	test_files.map do |file|
		spec = OpenStruct.new
    m = %r".*/([^/].*)_test.rb".match(file)
		class_name = titleize(m[1]) if m[1]
		spec.name = class_name
		spec.requirements = []
    File::readlines(file).each do |line| 
			if line =~ /^\s*should\s+\(?\s*["'](.*)["']/
				spec.requirements << $1
			end
		end
		spec
	end
end

def test_files
  test_list = FileList["#{APP_ROOT}/test/**/*_test.rb"]
	if ENV['for'] 
		test_list = test_list.grep(/#{ENV['for']}/i)
	end
	test_list
end  

# Stolen from inflector
def humanize(lower_case_and_underscored_word)
	lower_case_and_underscored_word.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
end

def camelize(lower_case_and_underscored_word)
	lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
end

def titleize(word)
	humanize(underscore(word)).gsub(/\b([a-z])/) { $1.capitalize }
end

def underscore(camel_cased_word)
	camel_cased_word.to_s.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
end
