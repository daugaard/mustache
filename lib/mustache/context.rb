class Mustache
  # A ContextMiss is raised whenever a tag's target can not be found
  # in the current context if `Mustache#raise_on_context_miss?` is
  # set to true.
  #
  # For example, if your View class does not respond to `music` but
  # your template contains a `{{music}}` tag this exception will be raised.
  #
  # By default it is not raised. See Mustache.raise_on_context_miss.
  class ContextMiss < RuntimeError;  end

  # A Context represents the context which a Mustache template is
  # executed within. All Mustache tags reference keys in the Context.
  class Context
    # Expect to be passed an instance of `Mustache`.
    def initialize(mustache)
      @stack = [mustache]
    end

    # A {{>partial}} tag translates into a call to the context's
    # `partial` method, which would be this sucker right here.
    #
    # If the Mustache view handling the rendering (e.g. the view
    # representing your profile page or some other template) responds
    # to `partial`, we call it and render the result.
    def partial(name)
      # Look for the first Mustache in the stack.
      mustache = mustache_in_stack

      # Call its `partial` method and render the result.
      mustache.render(mustache.partial(name), self)
    end

    # Find the first Mustache in the stack. If we're being rendered
    # inside a Mustache object as a context, we'll use that one.
    def mustache_in_stack
      @stack.detect { |frame| frame.is_a?(Mustache) }
    end

    # Adds a new object to the context's internal stack.
    #
    # Returns the Context.
    def push(new)
      @stack.unshift(new)
      self
    end
    alias_method :update, :push

    # Removes the most recently added object from the context's
    # internal stack.
    #
    # Returns the Context.
    def pop
      @stack.shift
      self
    end

    # Can be used to add a value to the context in a hash-like way.
    #
    # context[:name] = "Chris"
    def []=(name, value)
      push(name => value)
    end

    # Alias for `fetch`.
    def [](name)
      fetch(name, nil)
    end

    # Do we know about a particular key? In other words, will calling
    # `context[key]` give us a result that was set. Basically.
    def has_key?(key)
      !!fetch(key)
    rescue ContextMiss
      false
    end

    # Similar to Hash#fetch, finds a value by `name` in the context's
    # stack. You may specify the default return value by passing a
    # second parameter.
    #
    # If no second parameter is passed (or raise_on_context_miss is
    # set to true), will raise a ContextMiss exception on miss.
    def fetch( name, default ) 
					
			@stack.each do |frame|
		    	
		    	# Prevent infinite recursion
		    	if( (frame.is_a?(Mustache) && frame.context == self) || (frame.is_a?(Mustache::Context) && frame == self)) 
		    		next
		    	end
		    
		    	if frame.is_a?(Prime::Models::Document)
					
					model = Prime::Models::Model.get(frame['model']).latest
					
					# Find field and figure out what type it is
					model['fields'].each do |field|
						if( field["name"] == name || field["name"] == name.to_s )
							if( field["type"] == "reference" )
								# We should do some resolving of the reference!
								if( !frame[name.to_s].is_a? Prime::Models::Document )
									frame['content'][name] = Prime::Models::Document.get(frame['content'][name.to_s])
								end
							elsif field["type"] == "list" && field["list_type"]["type"] == "reference"
								# We should do some resolving of the list in question!
								old_list = frame['content'][name.to_s]
								new_list = Array.new
								old_list.each do |list_item|
									if( !list_item.is_a? Prime::Models::Document ) 
										new_list.push( Prime::Models::Document.get(list_item) )
									else
										new_list.push( list_item )
									end
								end unless not old_list.is_a? Array	
								frame['content'][name.to_s] = new_list					
							elsif field['type'] == "nested"
								frame['content'][name.to_s] = frame['content'][name.to_s].merge( {'__type' => "nested", "__model" => frame['model'], '__fieldname' => name.to_s}	)
							end
						end
					end				
					frame_data = frame['content']
					frame_data['_id'] = frame['_id']
				
				elsif frame['__type'] && frame['__type'] == "nested"
					
					model = Prime::Models::Model.get(frame['__model']).latest
					
					nested_fields = Array.new
					
					model['fields'].each do |field|
						if( field["name"] == frame['__fieldname'] )
							nested_fields = field["fields"]
						end
					end
					
					nested_fields.each do |field|
						if( field["name"] == name || field["name"] == name.to_s )
							if( field["type"] == "reference" )
								# We should do some resolving of the reference!
								if( !frame[name.to_s].is_a? Prime::Models::Document )
									frame[name.to_s] = Prime::Models::Document.get(frame[name.to_s])
								end
							elsif field["type"] == "list" && field["list_type"]["type"] == "reference"
								# We should do some resolving of the list in question!
								old_list = frame[name.to_s]
								new_list = Array.new
								old_list.each do |list_item|
									if( !list_item.is_a? Prime::Models::Document ) 
										new_list.push( Prime::Models::Document.get(list_item) )
									else
										new_list.push( list_item )
									end	
								end unless not old_list.is_a? Array	
								frame[name.to_s] = new_list					
							elsif field['type'] == "nested"
								frame[name.to_s] = frame[name.to_s].merge( {'__type' => "nested", "__model" => frame['model'], '__fieldname' => name.to_s}	)
							end
						end
					end
					
					frame_data = frame
				
				else 
				
					frame_data = frame
				
				end
				
		    	# Is this frame a hash?
		    	hash = frame_data.respond_to?(:has_key?)
				
		    	if hash && frame_data.has_key?(name)
		      		return frame_data[name]
		    	elsif hash && frame_data.has_key?(name.to_s)
		      		return frame_data[name.to_s]
		    	elsif !hash && frame_data.respond_to?(name)
		      		return frame_data.__send__(name)
		    	end

		  	end

		  	if default == :__raise || mustache_in_stack.raise_on_context_miss?
		    	raise ContextMiss.new("Can't find #{name} in #{@stack.inspect}")
		  	else
		    	default
		  	end

		end
  end
end
