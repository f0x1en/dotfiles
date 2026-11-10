--- @sync entry
-- Enter: go into folders (like l), open files with their opener
return {
	entry = function()
		local h = cx.active.current.hovered
		ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
	end,
}
