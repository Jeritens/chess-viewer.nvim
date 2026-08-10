local state = require("chess-viewer.state")
local config = require("chess-viewer.config")
local M = {}

M.ns_id = vim.api.nvim_create_namespace("chess-viewer")


local function fenToVirtualText(fen)
	local virtualText = {}
	local squareNum = 0
	local rowNum = 0
    local line = {}
	for char in fen:gmatch(".") do
		if tonumber(char) then
			for _ = 1, tonumber(char) do
				table.insert(
					line,
					{ config.options.unicode_pieces["s"], ((rowNum + squareNum) % 2 == 0) and "LightSquareWhite" or "DarkSquareWhite" }
				)
				squareNum = squareNum + 1
			end
		end
		if char:match("/") then
			rowNum = rowNum + 1
			table.insert(virtualText, line)
            line = {}
		end
		if char:match("%a") then
			local highlight = ""
			if char:match("%u") then
				highlight = ((rowNum + squareNum) % 2 == 0) and "LightSquareWhite" or "DarkSquareWhite"
			else
				highlight = ((rowNum + squareNum) % 2 == 0) and "LightSquareBlack" or "DarkSquareBlack"
			end
			table.insert(line, { config.options.unicode_pieces[char:lower()], highlight })
			squareNum = squareNum + 1
		end
	end
	table.insert(virtualText, line)
	return virtualText
end

local function showVirtualFenBoard(bufnr, line, fen)
    local virtualText = fenToVirtualText(fen)
    local is_above = config.options.mode == "any"
    local opts = { virt_lines =  virtualText, virt_lines_above = is_above }
    vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, line, 0, opts)
end


function M.removeBoards(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
end

function M.render_all(bufnr)
    M.removeBoards(bufnr)
    vim.cmd("highlight LightSquareWhite guibg=" .. config.options.colors.light_square .. " guifg=" .. config.options.colors.white_pieces )
    vim.cmd("highlight LightSquareBlack guibg=" .. config.options.colors.light_square .. " guifg=" .. config.options.colors.black_pieces)
    vim.cmd("highlight DarkSquareWhite guibg=" .. config.options.colors.dark_square .. " guifg=" .. config.options.colors.white_pieces)
    vim.cmd("highlight DarkSquareBlack guibg=" .. config.options.colors.dark_square .. " guifg=" .. config.options.colors.black_pieces)
    ---@type BoardBlock[]
    local blocks = state.get_blocks(bufnr)
    for _,v in pairs(blocks) do
        showVirtualFenBoard(bufnr, v.start_row, v.fens[1])
    end
end

return M
