
local u = FasterTravel.Utils or {}

local function stringIsEmpty(str)
	return str == nil or str == ""
end

local function stringStartsWith(str,value)
	return string.sub(str,1,string.len(value)) == value
end

local function stringTrim(str)
	if str == nil or str == "" then return str end 
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end 

local function copy(source,target)
	target = target or {}
	for i,v in ipairs(source) do
		table.insert(target,v)
	end
	return target
end

local function extend(source,target)
	target = target or {}
	for k,v in pairs(source) do 
		target[k]=v
	end 
	return target
end

local function toTable(value)
	local t = type(value)
	
	if t == "table" then
		return copy(value)
	elseif t == "function" then
		local tbl = {}
		for i in value do
			table.insert(tbl,i)
		end
		
		return tbl
	end
end

local function where(iter,predicate)
	local t = type(iter)
	
	if t == "table" then
		local tbl = {}
		for i,v in ipairs(iter) do
			if predicate(v) == true then
				table.insert(tbl,v)
			end
		end
		return tbl
	elseif t == "function" then
		local cur
		return function()
			repeat
				cur = iter()
			until cur == nil or predicate(cur) == true
			return cur
		end
	end
end

local function map(iter,func)
	local t = type(iter)
	if t == "table" then
		local tbl = {}
		for i,v in ipairs(iter) do
			tbl[i]=func(v)
		end
		return tbl
	elseif t == "function" then
		local cur
		return function()
			cur = iter()
			if cur == nil then return nil end
			return func(cur)
		end
	end
end

local function concatToString(...)
	return table.concat(map({...},function(a)
		return tostring(a)
	end))
end

local _lang

local function FormatStringLanguage(lang,str)
	if stringIsEmpty(str) == true then return str end
	lang = string.lower(lang)
	if lang == "en" then 
		return str
	else
		return zo_strformat("<<!AC:1>>", str)
	end 
end 

local function FormatStringCurrentLanguage(str)
	if _lang == nil then 
		_lang = GetCVar("language.2")
		_lang = string.lower(_lang)
	end 
	return FormatStringLanguage(_lang,str)
end

u.copy = copy
u.stringIsEmpty = stringIsEmpty
u.stringStartsWith = stringStartsWith
u.stringTrim = stringTrim
u.toTable = toTable
u.map = map
u.where = where 
u.extend = extend
u.FormatStringLanguage = FormatStringLanguage
u.FormatStringCurrentLanguage = FormatStringCurrentLanguage
u.concatToString = concatToString

FasterTravel.Utils = u