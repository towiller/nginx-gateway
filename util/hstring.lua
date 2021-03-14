local string = string

function string.split(delimiter, input)
	input = tostring(input)		
	delimiter = tostring(delimiter)

	if delimiter == '' then 
		return nil	
	end 

	local pos = 0
	local arr = {}
	for st, sp in function() return string.find(input, delimiter, pos, true) end do 
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end 

	table.insert(arr, string.sub(input, pos))
	return arr
end

return string
