class GenerateTable
  
	def initialize()
		@data2=""
		@data3=""
		@data4=""
		@vars=[]
		@values=[]
		@bracket=[]
	end

# report error
#
	def reportError(msg, i)
		if i!=-1  
			errline=@data2.slice(0,i)+'<SPAN STYLE="background:#000000"><FONT COLOR=#FF0000><B>'+@posvar+'</B></FONT></SPAN>'+@data2.slice(i+1)
		else 
			errline=''
		end		
		return '<FONT COLOR=#990000>'+msg+'</FONT><BR>'+errline
	end

# sort variables alphabetically
#
	def sortVariables()
		(0..@vars.size-1).each do |i|
			i+=1
			(i..@vars.size-1).each do |j|
				if @vars[i]>@vars[j]
					k=@vars[i]
					@vars[i]=@vars[j]
					@vars[j]=k
				end
			end
		end
	end

# -1 if the letter is not a variable, otherwise variable number
#
	def isVariable(let)
		(0..@vars.size-1).each do |j| 
			if let==@vars[j] 
				return(j)
			end
		end
		return(-1)
	end

# compute logic @data3 with no @brackets and return the logic value
#
	def compute(expr)

		data4=expr 
	
		j=0;
		while j<=data4.size
		
	      if !data4[j+1].nil?
				if data4[j+1].chr=='`' || data4[j+1].chr=="'"
					(data4[j].chr=='1') ? k="0" : k="1"
					data4=data4.slice(0,j).to_s+k+data4.slice(j+2..-1).to_s
					#j=j-1
				end
	      end
			j+=1
		end
	
		j=0
	   while(j<=data4.size)
	      if !data4[j+1].nil?
				if (data4[j].chr=='0' || data4[j].chr=='1') && (data4[j+1].chr=='0' || data4[j+1].chr=='1')
					(data4[j].chr=='1' && data4[j+1].chr=='1') ? k="1" : k="0"
					data4=data4.slice(0,j).to_s+k+data4.slice(j+2..-1).to_s
					#j=j-1;
				elsif (data4[j].chr=='0' || data4[j].chr=='1') && data4[j+1].chr=='^'
					(data4[j].chr==data4.charAt(j+2)) ? k="0" : k="1"
					data4=data4.slice(0,j).to_s+k+data4.slice(j+3..-1).to_s
					#j=j-1;
				end
	      end
			j+=1
		end
		k=0
		
		j=0
		while(j<data4.size) 	
			if data4[j].chr=='1'
				k=1
				return k
			end 
			j+=1
		end
		return k
	
	end

# main evaluation data
#

	def evaluateMe(exp)
	   @vars=[]
		@values=[]
		@bracket=[]
			
		data=exp
	
		@data2=''
	
		# parsing level one: remove white spaces
		#
		(0..data.size-1).each do |i|
			if data[i] > 32  
				@data2+=data[i].chr
			end
		end
		
		(0..@data2.size-1).each do |i|
			 
			@posvar=@data2[i].chr
			if @posvar!='`' && @posvar!="'" && @posvar!='+' && @posvar!='^' && @posvar!='(' && @posvar!=')'
			
				# found an invalid character
				#
				if @posvar<'a' || @posvar>'z'
					return reportError('Parse error: invalid character',i)
				end
	
				# found a variable
				#
				j = 0
				#(0..@vars.size).each do |j|
				while j<@vars.size do
					if @posvar==@vars[j] 
						break
					end
					j+=1
				end
				if j==@vars.size 
					@vars[j]=@posvar
				end
			end			
		end
	
		# parsing level three: find parentheses and operands validity
		#
		@parlevel=0
		@prev=0
		
		(0..@data2.size-1).each do |i|
		
			if !@data2[i+1].nil?
				@next = @data2[i+1].chr
			else
				@next = ""
			end 
			@posvar = @data2[i].chr
			
			if (@posvar=='+' && ((@prev!=')' && @prev!='`' && @prev!="'" && isVariable(@prev)<0) || ( @next!='(' && isVariable(@next)<0)))
			
				# misplaced +
				#
				return reportError('Parse error: misplaced "+"',i)
			end
			if (@posvar=='^' && ((@prev!=')' && @prev!='`' && @prev!="'" && isVariable(@prev)<0) || (@next!='(' && isVariable(@next)<0)))
			
				# misplaced ^
				#
				return reportError('Parse error: misplaced "^"',i)
			end
			if ((@posvar=='`' || @posvar=="'") && @prev!=')' && @prev!="'" && @prev!='`' && isVariable(@prev)<0)
			
				# misplaced `
				#
				return reportError('Parse error: misplaced "'+"'"+'"',i)
			end
			
			if @posvar=='(' 
				@parlevel+=1
			end
			
			if @posvar==')' 		
				if !@parlevel
					# too many ')' @brackets
					#
					return reportError('Parse error: parentheses mismatch',i)
				end
				@parlevel-=1
			end
			@prev=@posvar
		end
		
		if @parlevel!=0
			# to few ')' @brackets
			#
			return reportError('Parse error: parentheses missing',-1)
		end
		
		if @posvar=='+'
	
			# + at the end of input
			#
			return reportError('Parse error: misplaced "+"',i-1)
		end
	
		sortVariables()
	
		# evaluating the expression swap 1's and 0's for letters
		#
		nosteps=(1<<@vars.size)
		
		(0..@vars.size-1).each do |i| 
			@values[i]=0
		end
		
		k=0
		#s='<TABLE BORDER=1 BORDERCOLORLIGHT=#0000ff BORDERCOLORDARK=#000000 BGCOLOR=#a7b7c8><TR>'
		
		s=''
		(0..@vars.size-1).each do |i| 
			# s+='<TD><B>'+@vars[i]+'</TD>'
			s+=@vars[i]
		end
		s+="\n----------------------\n"
		#s+='<TD BGCOLOR=#cfc7da><B>out</TD></TR>'
	
		(0..nosteps).each do |i|
			# format output
			#s+'<TR>'
			#for(j=0;j<@vars.size;++j) s+='<TD>'+@values[j]+'</TD>';
	
			(0..@vars.size-1).each do |j| 
				s+=(@values[j].to_s+" ")
			end
			s+="|"
				
			#s+='<TD ALIGN=CENTER BGCOLOR=#cfc7da>';
			# replace letters by numbers
			#
			@data3=@data2		
			j=0
			while j < @data3.size do  				
				if (k=isVariable(@data3[j].chr))!=-1 
					@data3=@data3.slice(0,j)+@values[k].to_s+@data3.slice((j+1)..-1).to_s
				end
				j+=1
			end

			# evaluate.. sweep along parentheses to find which @values to evaluate first
			#
			@bracketno=0
			j=0			
			while j < @data3.size do			
				
				if @data3[j].chr=='(' 				
					@bracket[@bracketno] = j+1
					@bracketno+=1
				end
				
				if @data3[j].chr==')'
				
					# found first occurrence of closed @brackets.. i.e. all data within the @brackets
					# has no internal @brackets
					#
					k=compute(@bracket[@bracketno-1],j-1)
										
					@data3=@data3.slice(0,@bracket[@bracketno-1]-1).to_s + k.to_s + @data3.slice((j+1)..-1).to_s
					j=@bracket[@bracketno-1]-1
					@bracketno-=1
				end
				j+=1
			end
			
			k=compute(0,@data3.size-1)
			s+=k.to_s+'\n'
			j=@vars.size-1

			while j>=0 do
				@values[j]=1-@values[j]
				if @values[j] 
					break
				end
				j-=1
			end
		end
		
		
		return s
	end

end
