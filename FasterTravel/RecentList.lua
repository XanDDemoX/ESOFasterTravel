

local RecentList = FasterTravel.class()
FasterTravel.RecentList = RecentList

function RecentList:init(items,key,size)
	local lookup = {}
	local items = items or {}
	
	for i=1,#items do
		if i <= size then 
			lookup[items[i][key]] = i 
		else
			table.remove(items)
		end
	end
	
	self.push = function(self,key,value)
		local idx = lookup[value[key]]
		
		local hasValue = idx ~= nil
		
		local count = #items
		
		if hasValue == true then 
			lookup[value[key]] = nil
			table.remove(items,idx)
			
			count = count-1
			hasValue = false
			
			for i=1,count do
				lookup[items[i][key]] = i 
			end
		end
		
		if hasValue == false and count <= size then 
			for i = 1,count do
				lookup[items[i][key]]=i+1
			end
			if count == size then 
				local victim = items[count]
				lookup[victim[key]] = nil 
				table.remove(items)
			end
			table.insert(items,1,value)
			lookup[value[key]]=1
		end
		return self
	end

	self.items = function(self)
		local cur = 0
		local count = math.min(#items,size)
		return function()
			if cur < count then
				cur = cur + 1 
				return items[cur]
			end
			return nil
		end
	end
	
end