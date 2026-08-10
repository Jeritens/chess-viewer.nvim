local M = {}

M.defaults = {
    ---@type "markdown" | "any"
    mode = "markdown",
    -- mode = "any",
    fen_regex = "%w+/%w+/%w+/%w+/%w+/%w+/%w+/%w+",
    -- fen_regex = "%f[%a%d][rnbqkpRNBQKP1-8]+/[rnbqkpRNBQKP1-8]+/...",
    colors = {
        white_pieces = "#ffffff",
        black_pieces = "#000000",
        dark_square = "#b58863",
        light_square = "#D3C6AA",
    },

    unicode_pieces = {
        r = " 󰡛 ",
        n = " 󰡘 ",
        b = " 󰡜 ",
        q = " 󰡚 ",
        k = " 󰡗 ",
        p = " 󰡙 ",
        s = "   ",

        -- r = "󰡛",
        -- n = "󰡘",
        -- b = "󰡜",
        -- q = "󰡚",
        -- k = "󰡗",
        -- p = "󰡙",
        -- s = " ",
        -- r = "♖",
        -- n = "♘",
        -- b = "♗",
        -- q = "♕",
        -- k = "♔",
        -- p = "♙",
    }
}

M.options = {}

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", M.defaults, user_opts or {})
end

return M
