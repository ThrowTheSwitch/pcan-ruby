# Behaviors

module Behaviors
	def should(behave,&block)
		mname = "test_should_#{behave}"
		if block
			define_method mname, &block
		else
			define_method mname do 
			  flunk "#{self.class.name.sub(/Test$/,'')} should #{behave}"
			end
		end
	end
end
