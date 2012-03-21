class Array

	# Get Even / Odd elements reference to values
	# Also any combination of MOD & OFFSET can be used
	def mod_val(mod_by=1, offset=0) 
		column = []
		self.each do |i|
			column << i if i % mod_by == offset
		end
		column
	end

	# Get Even / Odd elements reference to position
	# Also any combination of MOD & OFFSET can be used
	def mod_pos(mod_by=1, offset=0) 
		column = []
		self.each_index do |i|
			column << self[i] if i % mod_by == offset
		end
		column
	end

	# Delete multiple elements from array
	def delete_all(arr_del)
		arr_del.each do |i|
			self.delete(i)
		end
		self
	end
	
	def not_include(arr_val)
		collection = []
		arr_val.each do |w|
			collection += w.to_a if !self.include? w
		end
		collection
	end

end


class Hash

	# Sort Hash by Index or Value
	def sort_on(field="index")
		if field=="index"
			self.sort_by{|a,b| a}
		elsif field=="value"
			self.sort_by{|a,b| b}
		else
			self
		end
	end

end

class String
	# Delete multiple elements from array
	def delete_all(arr_del)
		arr_del.each do |i|
			self.delete(i)
		end
		self
	end

	def scan_all(arr_del)
		arr_del.each do |i|
			return true if self.scan(i).length != 0
		end
		return false
	end

	def replace_with_space(arr_str)
		arr_str.each do |s|
			self.gsub!("#{s}", " #{s} ")
		end
		self
	end
end