---@type table<integer, BoardBlock[]>
local state = {}

local M = {}

---@param bufnr integer
---@return BoardBlock[]
function M.get_blocks(bufnr)
    return state[bufnr]
end

---@param bufnr integer
---@param blocks BoardBlock[]
function M.update_blocks(bufnr,blocks)
    state = {}
    for k,v in pairs(blocks) do 
        if v.type == "pgn" then
            -- TODO parse pgn. for every move generate pgn, hover over detection
            v.fens = {"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"}
        end
    end
    state[bufnr] = blocks
    --- do magic compare etc
end

return M
