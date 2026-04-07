vim.api.nvim_create_user_command('ChessViewer', function(opts)
    require("chess-viewer").showFENBoard()
    -- local args = opts.args
    -- if args == nil then
    --     require("chess-viewer").showFENBoard()
    -- end
    -- if args == "pgn" then
    --     require("chess-viewer").pgn()
    -- end
end, {nargs = "?"})

