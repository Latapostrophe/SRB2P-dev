-- keynames, just to avoid clogging KeyLib

rawset(_G, "SYS_KeyNames", {})

local t = SYS_KeyNames	-- shortcut

-- god this is boring .......
t[0] = "KEY0"
t[KEY_SPACE] = "SPACE"
t[KEY_ENTER] = "ENTER"

t[KEY_CAPSLOCK] = "CAPS LOCK"
t[KEY_TAB] = "TAB"
t[KEY_ESCAPE] = "ESCAPE"
t[KEY_BACKSPACE] = "BACKSPACE"
t[KEY_NUMLOCK] = "NUMLOCK"
--t[KEY_SCROLLLOCK] = "SCROLLLOCK"

t[KEY_LSHIFT] = "SHIFT"
t[KEY_RSHIFT] = "RSHIFT"
t[KEY_LCTRL] = "CTRL"
t[KEY_RCTRL] = "RCTRL"
t[KEY_LALT] = "ALT"
t[KEY_RALT] = "RALT"

t[KEY_KEYPAD7] = "KEYPAD 7"
t[KEY_KEYPAD8] = "KEYPAD 8"
t[KEY_KEYPAD9] = "KEYPAD 9"
t[KEY_MINUSPAD] = "KEYPAD -"
t[KEY_KEYPAD4] = "KEYPAD 4"
t[KEY_KEYPAD5] = "KEYPAD 5"
t[KEY_KEYPAD6] = "KEYPAD 6"
t[KEY_KEYPAD1] = "KEYPAD 1"
t[KEY_KEYPAD2] = "KEYPAD 2"
t[KEY_KEYPAD3] = "KEYPAD 3"
t[KEY_KEYPAD0] = "KEYPAD 0"
t[KEY_PLUSPAD] = "KEYPAD +"
t[KEY_KPADDEL] = "KEYPAD ."

t[KEY_F1] = "F1"
t[KEY_F2] = "F2"
t[KEY_F3] = "F3"
t[KEY_F4] = "F4"
t[KEY_F5] = "F5"
t[KEY_F6] = "F6"
t[KEY_F7] = "F7"
t[KEY_F8] = "F8"
t[KEY_F9] = "F9"
t[KEY_F10] = "F10"
t[KEY_F11] = "F11"
t[KEY_F12] = "F12"


-- from > 32 to < 128, we can use str:char
for i = 33, 127 do
	local k = string.char(i)
	SYS_KeyNames[i] = (k == "`") and "Tilde" or k
end

-- extended scancodes
t[KEY_ARROWU] = "UP ARROW"
t[KEY_ARROWD] = "DOWN ARROW"
t[KEY_ARROWL] = "LEFT ARROW"
t[KEY_ARROWR] = "RIGHT ARROW"

-- gamepads
-- somehow they're called joysticks like they're so kinda atari garbage lmao

-- JOYx
for i = 0, 31
	t[KEY_JOY1 +i] = "JOY"..(i+1)
end

-- HATS aren't so kind to us however
t[KEY_HAT1+0] = "HATUP"
t[KEY_HAT1+1] = "HATDOWN"
t[KEY_HAT1+2] = "HATLEFT"
t[KEY_HAT1+3] = "HATRIGHT"
t[KEY_HAT1+4] = "HATUP2"
t[KEY_HAT1+5] = "HATDOWN2"
t[KEY_HAT1+6] = "HATLEFT2"
t[KEY_HAT1+7] = "HATRIGHT2"
t[KEY_HAT1+8] = "HATUP3"
t[KEY_HAT1+9] = "HATDOWN3"
t[KEY_HAT1+10] = "HATLEFT3"
t[KEY_HAT1+11] = "HATRIGHT3"
t[KEY_HAT1+12] = "HATUP4"
t[KEY_HAT1+13] = "HATDOWN4"
t[KEY_HAT1+14] = "HATLEFT4"
t[KEY_HAT1+15] = "HATRIGHT4"

-- MOUSEx
for i = 0, 7
	t[KEY_MOUSE1+i] = "MOUSE"..(i+1)
end

-- SEC_MOUSEx
for i = 0, 7
	t[KEY_2MOUSE1+i] = "SEC_MOUSE"..(i+1)
end

t[KEY_MOUSEWHEELUP] = "Wheel 1 UP"
t[KEY_MOUSEWHEELDOWN] = "Wheel 1 Down"	-- what the FUCK are these naming conventions I stg
t[KEY_2MOUSEWHEELUP] = "Wheel 2 UP"
t[KEY_2MOUSEWHEELDOWN] = "Wheel 2 Down"

-- DBLMOUSEx	:wut:
for i = 0, 7
	t[KEY_DBLMOUSE1+i] = "DBLMOUSE"..(i+1)
end
for i = 0, 7
	t[KEY_DBL2MOUSE1+i] = "DBLSEC_MOUSE"..(i+1)
end

-- support from here is idiotic, we don't support splitscreen nor joypad double inputs.