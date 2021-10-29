-- render menus
rawset(_G, "renderMenus", function(v, mo)
	if not mo.m_menu return end
	if not M_menus[mo.m_menu] return end
	local m = M_menus[mo.m_menu]

	-- the drawer for the menu itself
	if m.drawer
		m.drawer(v, mo)
	end

	-- handle submenu stuff
	if not mo.m_submenu return true end
	if not m[mo.m_submenu] return true end
	local s = m[mo.m_submenu]

	if s.drawer
		s.drawer(v, mo, mo.m_menuchoices[mo.m_submenu])
	end

	return true
end)