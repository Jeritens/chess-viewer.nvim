---@meta

---@class BoardBlock
---@field extmark_id integer?
---@field type "fen" | "pgn"
---@field start_row integer
---@field end_row integer
---@field text string
---@field fens string[]
---@field current_ply integer
---@field dirty boolean

---@class BufferState
---@field blocks BoardBlock[]
