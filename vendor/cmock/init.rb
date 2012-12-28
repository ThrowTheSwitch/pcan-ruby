# This allows CMock to automatically appear in the test environment of
# your Rails app.  Drop the entire CMock project beneath your_proj/vendor/plugins
# and you'll be all set.
if RAILS_ENV == 'test'
	require 'cmock'
	class Test::Unit::TestCase
		include CMock
	end
end
