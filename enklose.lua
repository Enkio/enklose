enklose = {}

local pairs = {
	['('] = ')',
	['{'] = '}',
	['['] = ']',
	['"'] = '"',
	["'"] = "'",
	["<"] = ">"
}

function enklose.autoclose(char)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, 0)[1] or ""

	if char == '<' and vim.bo.filetype == 'c' then
		return char
	end
	if col >= #line then
		if char == '{' and vim.bo.filetype == 'c' and line:sub(col , col) == ')' then
			return "<CR>{}<Left><CR><tab><CR><UP><Right>"
		else
			return char .. pairs[char] .. "<Left>" 
		end
	else
		return char
	end
end

function enklose.autoblock(char)
	-- return to normal mode for update visual area
	-- vim.api.nvim_input("<Esc>")
	-- -- get start of selection
	-- -- local start_block = vim.fn.getpos("v")
	-- local start_block = vim.fn.getpos("'<")
	-- -- get end of selection
	-- local end_block = vim.fn.getpos("'>")
	local start_block = vim.api.nvim_buf_get_mark(0, '<')
	local end_block = vim.api.nvim_buf_get_mark(0, '>')
	print("---------")
	print("startline : " .. start_block[1])
	print("start col : " .. start_block[2])
	print("-------")
	print("endline : " .. end_block[1])
	print("end col : " .. end_block[2])
	-- swap if cursor before end visual block
	-- if end_block[2] < start_block[2] then
	-- 	local tmp = end_block
	-- 	end_block = start_block
	-- 	start_block = tmp
	-- end

	local start_line = vim.api.nvim_buf_get_lines(0, start_block[1] - 1, start_block[1], 0)[1] or ""
	local end_line = vim.api.nvim_buf_get_lines(0, end_block[1] - 1, end_block[1], 0)[1] or ""
	print("-----------")
	print("start line str : " .. start_line)
	
	-- if end_block[2] == int max (2147483647) : end_block[2] = #end_line
	if end_block[2] == 2147483647 then
		end_block[2] = #end_line
	end
	--
	-- cut line, keep start
	local startlength = #start_line
	print(startlength)

	start_line = string.sub(start_line, start_block[2] + 1, startlength)
	print("start line to copy : " .. start_line)
	-- insert char to start -1
	vim.api.nvim_buf_set_text(
		0, 
		start_block[1] - 1,
		start_block[2], 
		start_block[1] - 1, 
		startlength,
		{"(" .. start_line})
	-- cut line, keep end
	local endlength = #end_line
	print("end line : " .. end_line)
	end_line = string.sub(end_line, end_block[2] +1, endlength)
	print("end line to copy : " .. end_line)
	-- insert char pair to end +1
	vim.api.nvim_buf_set_text(
		0, 
		end_block[1] - 1, 
		end_block[2] + 1, 
		end_block[1] - 1, 
		endlength,
		{")" .. end_line})
end

function enklose.autodelete()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_buf_get_lines(0, row - 1, row, 0)[1] or ""
	local prev = line:sub(col , col)
	local next = line:sub(col + 1, col + 1)

	if next == pairs[prev] then
		return "<Left><Del><Del>"
	else
		return "<BS>"
	end
end

function enklose.setup()
	vim.keymap.set('i', '(', function() return enklose.autoclose("(") end,{expr = true, noremap = true})
	vim.keymap.set('i', '{', function() return enklose.autoclose("{") end,{expr = true, noremap = true})
	vim.keymap.set('i', '[', function() return enklose.autoclose("[") end,{expr = true, noremap = true})
	vim.keymap.set('i', '"', function() return enklose.autoclose('"') end,{expr = true, noremap = true})
	vim.keymap.set('i', "'", function() return enklose.autoclose("'") end,{expr = true, noremap = true})
	vim.keymap.set('i', "<", function() return enklose.autoclose("<") end,{expr = true, noremap = true})
-- [[:command]] -- execute a cmd line
	vim.keymap.set('v', '<C-9>', [[:<C-u> lua enklose.autoblock('(')<CR>]], {noremap = true})
	--vim.keymap.set('i', '<CR>', function() return enklose.autoindent() end,{expr = true, noremap = true})
	vim.keymap.set('i', '<BS>', function() return enklose.autodelete() end, {expr = true, noremap = true})
end
return enklose
