local M = {}
-- rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
-- r1bqkb1r/ppp2ppp/2p2n2/8/4P3/8/PPPP1PPP/RNBQKB1R w KQkq - 0 5

local namespace = vim.api.nvim_create_namespace("chessviewer")
local extmarkIds = {}

local WHITE = "#ffffff"
local BLACK = "#000000"
local DARK_SQUARE = "#b58863"
local LIGHT_SQUARE = "#D3C6AA"

local unicode_pieces = {
    r = "󰡛 ",
    n = "󰡘 ",
    b = "󰡜 ",
    q = "󰡚 ",
    k = "󰡗 ",
    p = "󰡙 ",
    -- r = "♖",
    -- n = "♘",
    -- b = "♗",
    -- q = "♕",
    -- k = "♔",
    -- p = "♙",
}

function M.showVirtualText()
    local opts = { virt_lines = { { { "test", "normal" } } } }

    local id = vim.api.nvim_buf_set_extmark(0, namespace, 10, 0, opts)
    table.insert(extmarkIds, id)
end

local function parseFENLines(lines)
    local fen = {}
    for k, v in pairs(lines) do
        local candidate = v:match("%w+/%w+/%w+/%w+/%w+/%w+/%w+/%w+")
        if candidate then
            fen[k] = candidate
        else
        end
    end
    return fen
end

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
					{ "  ", ((rowNum + squareNum) % 2 == 0) and "LightSquareWhite" or "DarkSquareWhite" }
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
			table.insert(line, { unicode_pieces[char:lower()], highlight })
			squareNum = squareNum + 1
		end
	end
	table.insert(virtualText, line)
	return virtualText
end

local function showVirtualFenBoard(line, fen)
    local virtualText = fenToVirtualText(fen)
    local opts = { virt_lines =  virtualText }
    local id = vim.api.nvim_buf_set_extmark(0, namespace, line-1, 0, opts)
end


local function showFENBoard()
    vim.cmd("highlight LightSquareWhite guibg=" .. LIGHT_SQUARE .. " guifg=" .. WHITE)
    vim.cmd("highlight LightSquareBlack guibg=" .. LIGHT_SQUARE .. " guifg=" .. BLACK)
    vim.cmd("highlight DarkSquareWhite guibg=" .. DARK_SQUARE .. " guifg=" .. WHITE)
    vim.cmd("highlight DarkSquareBlack guibg=" .. DARK_SQUARE .. " guifg=" .. BLACK)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local fens = parseFENLines(lines)
    for k, v in pairs(fens) do
        showVirtualFenBoard(k, v)
    end
end

function M.setup()
    vim.api.nvim_create_user_command('ChessViewer', function()
        showFENBoard()
    end, {})
end

-- M.showVirtualText()

return M

