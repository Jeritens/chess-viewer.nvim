local config = require("chess-viewer.config")


local function parseFENLines(lines)
    local fen = {}
    for k, v in pairs(lines) do
        local candidate = v:match(config.options.fen_regex)
        if candidate then
            fen[k-1] = candidate
        else
        end
    end
    return fen
end

local M = {}

---@return BoardBlock[]
function M.find_blocks(bufnr)

    local mode = config.options.mode
    if mode == "markdown" then
        return M.find_block_markdown(bufnr)
    elseif mode == "any" then
        return M.find_block_any(bufnr)
    end
    return {}
end

---@return BoardBlock[]
function M.find_block_markdown(bufnr)
    local blocks = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local new_block ={}
    local is_in_block = false

    for k, v in ipairs(lines) do
        local line = vim.trim(v:lower())
        if line:match("^```%s*fen") then
            is_in_block = true
            new_block = {
                type = "fen",
                start_row = k-1,
                text = "",
                current_ply = 0,
                dirty= true,
            }
        elseif line:match("^```%s*pgn") then
            is_in_block = true
            new_block = {
                type = "pgn",
                start_row = k-1,
                text = "",
                current_ply = 0,
                dirty= true,
            }
        elseif is_in_block and line:match("^```") then
            is_in_block = false
            new_block.end_row = k-1

            local parsed = new_block.text:match(config.options.fen_regex)
            new_block.fens = {parsed}
            table.insert(blocks, new_block)
        elseif is_in_block then
            new_block.text = new_block.text .. " " .. v
        end

    end
    return blocks
end

---@return BoardBlock[]
function M.find_block_any(bufnr)
    local blocks = {}

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local fens = parseFENLines(lines)
    for k, v in pairs(fens) do
        ---@type BoardBlock
        local block = {
            type = "fen",
            start_row = k,
            end_row = k,
            text = v,
            fens = {v},
            current_ply = 0,
            dirty= true,
        }
        table.insert(blocks, block)
    end
    print(#blocks)
    return blocks

end

return M
