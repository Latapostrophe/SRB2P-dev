-- srb2 drawindex font drawing code...

rawset(_G, "cv_commandhelp",
	CV_RegisterVar({
		  name = "commandhelp",
		  defaultvalue = 1,
		  flags = CV_SAVE,
		  PossibleValue = CV_OnOff,
	})
)

local ascii_03d = {}
for i = 0, 255	-- generate ascii %03d table so we don't have to do string.format everytime, this function is very slow:
	ascii_03d[i] = string.format("%03d", tostring(i))
end

-- font kerning: shift the letter width by a set number of pixels if that helps make em look better
rawset(_G, "V_fontKerning", {})

V_fontKerning["NFNT"] = {}
for i = 0, 255 do
	V_fontKerning["NFNT"][string.char(i)] = FRACUNIT/2
end
V_fontKerning["NFNT"][-1] = FRACUNIT	-- -1 is used for dropshadow

rawset(_G, "V_drawLetter", function(v, x, y, str, prefix, flags, color, scale)
	scale = $ or FRACUNIT/2
	color = $ or 0

	v.drawIndex(x, y, scale, v.cachePatch(prefix..ascii_03d[str:byte()]), flags, color)
end)

local function V_getKerning(prefix, char)
	return V_fontKerning[prefix] and V_fontKerning[prefix][char] or 0
end

-- Calls C version
rawset(_G, "V_stringWidth", function(v, str, prefix, flags, scale)
	return v.genericStringWidth(str, prefix, scale)
end)

-- Deprecated version of the function
rawset(_G, "V_stringWidth_deprecated", function(v, str, prefix, flags, scale)
	str = tostring(str)
	if not (v and str and prefix) return 0 end
	scale = $ or FRACUNIT/2
	local xoffs = 0

	for i = 1, str:len()
		local s = str:sub(i, i)

		if V_isControlChar(s)
			continue
		end

		if not v.patchExists(prefix..ascii_03d[s:byte()]) -- patch doesn't exist, assume it's a space:
			xoffs = $+10*scale
			continue
		end
		local pp = v.cachePatch(prefix..ascii_03d[s:byte()])
		xoffs = $+ pp.width*scale + V_getKerning(prefix, s)
	end
	return xoffs
end)

-- special hex chars that change the color
local chr_to_color = {
	["\x80"] = 0,	-- white
	["\x81"] = 180,	-- magenta
	["\x82"] = 73,	-- yellow
	["\x83"] = 103,	-- green
	["\x84"] = 151,	-- blue
	["\x85"] = 35,	-- red
	["\x86"] = 20,	-- grey
	["\x87"] = 54,	-- orange
	["\x88"] = 141,	-- sky
	["\x89"] = 164,	-- purple
	["\x8A"] = 123,	-- aqua
	["\x8B"] = 96,	-- peridot
	["\x8C"] = 147,	-- azure
	["\x8D"] = 230,	-- brown
	["\x8E"] = 202,	-- pink
	["\x8F"] = 24,	-- black
}

rawset(_G, "V_isControlChar", function(s)
	if not s:byte() return end
	return (s:byte() >= 128 and s:byte() <= (128 + 15))
end)

-- full wordwrapping with font support
rawset(_G, "STR_WordWrap", function(v, str, w, font, scale, ignore)
	if not v  print("No hud"); return end
	if not str print("No string"); return end
	if not w print("No len"); return {str} end

	if ignore
		str = str:gsub("\n", " ")
		str = str:gsub("  ", " ")
	end

	font = $ or "NFNT"
	scale = $ or FRACUNIT/2
	w = $*FRACUNIT

	local t = {}
	local index = 1
	local spaces = {}
	local lastspace = 0
	local lastcontrolchar
	local x = 0

	local i = 1

	while i < str:len()
		local c = str:sub(i, i)

		--print("read 1 "..c)

		if c == "\n"
			--print("Setup space at "..i)
			x = 0
			spaces[#spaces+1] = i
			lastspace = 0
			i = $+1
			continue

		elseif V_isControlChar(c)
			i = $+1
			continue	-- don't care
		end


		if c == " "
			lastspace = i
		end

		x = $+ V_stringWidth(v, c, font, scale)

		if x > w and lastspace
			--print("Too long, setup space at "..lastspace)
			spaces[#spaces+1] = lastspace
			i = lastspace	-- set the reading cursor back to the last space
			lastspace = 0
			x = 0
		end
		i = $+1
	end

	-- now build the string in the table
	for j = 1, str:len()
		local c = str:sub(j, j)

		--print("read 2 "..i.."|"..tostring(spaces[index]))

		if j == spaces[index]
			index = $+1
			if lastcontrolchar
				t[index] = $ or ""
				t[index] = $..lastcontrolchar	-- add last seen control char (for coloured text)
				lastcontrolchar = nil
			end
			continue
		end

		if V_isControlChar(c)
			lastcontrolchar = c
		end

		t[index] = $ or ""
		t[index] = $..c
	end

	return t
end)

-- quick wordwrapping
-- assumes that every character is 8 pixels of absolute size (320x200)

rawset(_G, "STR_WordWrap8", function(str, w, ignore)
	if not str print("No string"); return end
	if not w print("No len"); return {str} end

	if ignore
		str = str:gsub("\n", " ")
		str = str:gsub("  ", " ")
	end

	local t = {}
	local index = 1
	local spaces = {}
	local lastspace = 0
	local x = 0

	for i = 1, str:len()
		local c = str:sub(i, i)

		--print("read 1 "..c)

		if c == "\n"
			--print("Setup space at "..i)
			x = 0
			spaces[#spaces+1] = i
			lastspace = 0
			continue

		elseif V_isControlChar(c)
			continue	-- don't care
		end

		if c == " "
			lastspace = i
		end

		x = $+ 8 --V_stringWidth(v, c, font, scale)
		--print(x)

		if x > w and lastspace
			--print("Too long, setup space at "..lastspace)
			spaces[#spaces+1] = lastspace
			lastspace = 0
			x = 0
		end
	end

	-- now build the string in the table
	for i = 1, str:len()
		local c = str:sub(i, i)

		--print("read 2 "..i.."|"..tostring(spaces[index]))

		if i == spaces[index]
			index = $+1
			continue
		end

		t[index] = $ or ""

		t[index] = $..c
	end

	return t
end)

rawset(_G, "STR_WWToString", function(t)
	local str = ""
	for i = 1, #t
		if t[i]
			str = $..t[i].."\n"
		end
	end

	return str
end)

-- Call C version.
rawset(_G, "V_drawString", function(v, x, y, str, prefix, flags, alignment, color1, color2, scale)
	v.genericString(x*FRACUNIT, y*FRACUNIT, str, prefix, flags, alignment or "", color1, color2 or 0, scale)
end)

-- Old version of drawstring
rawset(_G, "V_drawString_deprecated", function(v, x, y, str, prefix, flags, alignment, color1, color2, scale)

	if v.genericString
		v.genericString(x*FRACUNIT, y*FRACUNIT, str, prefix, flags, alignment or "", color1, color2 or 0, scale)
		return
	end

	str = tostring(str)
	if not (v and tonumber(x)~=nil and tonumber(y)~=nil and str and prefix) return end
	color1 = $ or 0
	scale = $ or FRACUNIT/2

	x = $<<FRACBITS
	y = $<<FRACBITS	-- don't break compability...

	local xoffs = 0
	local yoffs = 0

	-- alignment coordinate adjustment:
	if alignment == "right"
		x = $ - V_stringWidth(v, str, prefix, flags, scale)
	elseif alignment == "center"
		x = $ - V_stringWidth(v, str, prefix, flags, scale)/2
	end

	for i = 1, str:len()
		local s = str:sub(i, i)
		local b = s:byte()

		if s == "\n"	-- line break
			yoffs = $+16*scale
			xoffs = 0
			continue
		end

		-- read control characters:
		if V_isControlChar(s)
			color1 = chr_to_color[s]
			continue
		end

		if not v.patchExists(prefix..ascii_03d[s:byte()]) -- patch doesn't exist, assume it's a space:
			xoffs = $+10*scale
			continue
		end

		local pp = v.cachePatch(prefix..ascii_03d[s:byte()])

		if color2 ~= nil
			local dshadow = V_fontKerning[prefix] and V_fontKerning[prefix][-1] or 2<<FRACBITS
			v.drawIndex((x+xoffs), (y+yoffs+dshadow), scale, pp, flags, color2)
		end
		v.drawIndex(x+xoffs, y+yoffs, scale, pp, flags, color1)
		xoffs = $+ pp.width*scale + V_getKerning(prefix, s)
	end
end)

-- Builds strings for commands from the data table supplied.

-- Did you know? Kanade has a great butt!
local butt_constants = {
	"BUTT_A",
	"BUTT_B",
	"BUTT_C",
	"BUTT_L",
	"BUTT_R",
	"BUTT_DPAD"
}
for i = 1, #butt_constants
	rawset(_G, butt_constants[i], 2^(i-1))
end

local butt_2_char = {
	[BUTT_A] = "\x90",
	[BUTT_B] = "\x91",
	[BUTT_C] = "\x92",
	[BUTT_L] = "\x93",
	[BUTT_R] = "\x94",
	[BUTT_DPAD] = "\x95",
}

/*
	Data table:

	{
		{constant1|constant2|constant3(...), action},
		{repeat }.....
	}

*/

rawset(_G, "V_buildCommandString", function(data)

	local str = ""

	for i = 1, #data

		if i > 1
			str = $.." "
		end

		local buttnums = data[i][1]
		for j = 1, #butt_constants
			if buttnums & (2^(j-1))
				str = $..butt_2_char[buttnums & (2^(j-1))]
			end
		end

		str = $..":"..data[i][2]
	end
	return str
end)

-- quick function that draws standardized button inputs:
rawset(_G, "V_drawCommands", function(v, data)
	if not cv_commandhelp.value return end
	local str = V_buildCommandString(data)
	V_drawString(v, 318, 191, str, "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right", 0, 31)
end)
