local config = require("chess-viewer.config")
local detector = require("chess-viewer.detector")
local state = require("chess-viewer.state")
local renderer = require("chess-viewer.renderer")

local M = {}

local my_group = vim.api.nvim_create_augroup("ChessViewer", { clear = true })

function M.pgn()
     require("chess-viewer.pgn_to_fen").pgn_to_fen()
end

function M.setup(opts)
    config.setup(opts)
    vim.api.nvim_create_autocmd({"BufEnter", "TextChanged", "InsertLeave"},{
        group = my_group,
        pattern = "*.md",
        callback = function(ev)
            local blocks = detector.find_blocks(ev.buf)
            state.update_blocks(ev.buf, blocks)
            renderer.render_all(ev.buf)
            -- detect boards, update state, render
        end
    })
    -- print(vim.inspect(board))
    -- add cursor moved
end

return M
