local M = {}

-- 2d array
-- file(column), row -> e4 -> board[5][4]
local board = {}
local half_moves = 0
local can_white_castle_long = true
local can_white_castle_short = true
local can_black_castle_long = true
local can_black_castle_short = true
local half_moves_since_pawn_or_capture = 0
local en_passant = "-"


local move_piece
local parse_pgn
local reset
local to_fen
local init_board
local find_piece
local get_target_square
local file_to_number
local set_board_square
local can_move_to
local get_disambigious_file
local get_disambigious_rank
local number_to_file
-- TODO
-- multi candidates
-- en passant without optimizing (wiki definition)

-- refactor:
-- function order for scope (bottom up)
-- game state instead of local state
-- game, boad and square types (square: file, row) less parsing
-- board init (define rows and use those instead of ifs

-- can move refactores
-- table of fucntions for can_move
--simpler knight logic 2 and 1 or 1 and 2
--can slide (from to piece)
-- less .. operation, instead table concat
-- 

function M.pgn_to_fen(pgn)
    -- pgn =
    -- "1. e4 c6 2. d4 d5 3. Nc3 dxe4 4. Nxe4 Nd7 5. Ng5 Ngf6 6. Bd3 e6 7. N1f3 h6 8. Nxe6 Qe7 9. O-O fxe6 10. Bg6+ Kd8 11. Bf4 b5 12. a4 Bb7 13. Re1 Nd5 14. Bg3 Kc8 15. axb5 cxb5 16. Qd3 Bc6 17. Bf5 exf5 18. Rxe7 Bxe7 19. c4 1-0"
    -- pgn = "1. e8=Q b1=R"
    -- pgn = "1. e4 e5 2. f4 exf4 3. g4"
    -- pgn = "1. d4 e5 2. dxe5 f6 3. exf6 h6 4. fxg7 b6 5. gxh8=Q"
    -- pgn = "1. Nf3 Nf6 2. Nd4 Ng4 3. Nc3 Ne3 4. Ncb5"
    -- pgn = "1. e4 e5 2. Bd3 Bd6 3. Bc4 Bc5 4. d3 Nf6 5. Bg5"
    -- pgn = "1. a4 a5 2. Ra3 h5 3. Rc3 Ra6 4. h4 Rhh6 5. Rhh3 Rac6 6. e3 Rhe6 7. Qf3 f6 8. Qxh5+ g6"
    -- pgn =
    -- "1. d4 d5 2. Nf3 Nf6 3. e3 e5 4. dxe5 Bb4+ 5. Bd2 Bg4 6. Bd3 Bxd2+ 7. Qxd2 Bxf3 8. gxf3 Nc6 9. Nc3 Nxe5 10. O-O-O"
    -- pgn = "1. d4 c5 2. d5 e5"
    pgn = "1. e4 e5 2. a4 h5 3. Ra3 Rh6 4. Ke2 Ke7"
    reset()
    local moves = parse_pgn(pgn)
    for k, v in pairs(moves) do
        print(k, v)
        move_piece(v)
        print(to_fen())
    end
    return to_fen()
end

reset      = function()
    init_board()
    can_white_castle_long = true
    can_white_castle_short = true
    can_black_castle_long = true
    can_black_castle_short = true
    half_moves_since_pawn_or_capture = 0
    en_passant = "-"
    half_moves = 0
end

init_board = function()
    for c = 1, 8 do
        board[c] = {}
        for r = 1, 8 do
            if r == 2 then
                board[c][r] = "P"
            elseif r == 1 then
                if c == 1 or c == 8 then
                    board[c][r] = "R"
                elseif c == 2 or c == 7 then
                    board[c][r] = "N"
                elseif c == 3 or c == 6 then
                    board[c][r] = "B"
                elseif c == 4 then
                    board[c][r] = "Q"
                elseif c == 5 then
                    board[c][r] = "K"
                else
                    print("error in init")
                end
            elseif r == 7 then
                board[c][r] = "p"
            elseif r == 8 then
                if c == 1 or c == 8 then
                    board[c][r] = "r"
                elseif c == 2 or c == 7 then
                    board[c][r] = "n"
                elseif c == 3 or c == 6 then
                    board[c][r] = "b"
                elseif c == 4 then
                    board[c][r] = "q"
                elseif c == 5 then
                    board[c][r] = "k"
                else
                    print("error in init")
                end
            else
                board[c][r] = "."
            end
        end
    end
end

parse_pgn  = function(pgn)
    local moves = {}
    for move in string.gmatch(pgn, "%S+") do
        local i = string.find(move, "%.")
        if i == nil then
            table.insert(moves, move)
        end
    end
    return moves
end

move_piece = function(move)
    local is_white = half_moves % 2 == 0
    --castle check and checkmate....
    if string.match(move, "O-O-O") ~= nil then
        if is_white then
            board[5][1] = "."
            board[1][1] = "."
            board[3][1] = "K"
            board[4][1] = "R"
            can_white_castle_short = false
            can_white_castle_long = false
            can_white_castle_short = false
            can_white_castle_long = false
        else
            board[5][1] = "."
            board[1][1] = "."
            board[3][1] = "k"
            board[4][1] = "r"
            can_black_castle_short = false
            can_black_castle_long = false
        end
        half_moves = half_moves + 1
        half_moves_since_pawn_or_capture = half_moves_since_pawn_or_capture + 1
        return
    end
    if string.match(move, "O-O") ~= nil then
        if is_white then
            board[5][1] = "."
            board[8][1] = "."
            board[7][1] = "K"
            board[6][1] = "R"
            can_white_castle_short = false
            can_white_castle_long = false
        else
            board[5][8] = "."
            board[8][8] = "."
            board[7][8] = "k"
            board[6][8] = "r"
            can_black_castle_short = false
            can_black_castle_long = false
        end
        half_moves = half_moves + 1
        half_moves_since_pawn_or_capture = half_moves_since_pawn_or_capture + 1
        return
    end
    local is_capture = string.find(move, "x") ~= nil
    local is_promotion = string.find(move, "=") ~= nil
    local piece_moved = string.sub(move, 1, 1)
    if string.match(piece_moved, "%l") ~= nil then
        piece_moved = "P"
    end
    local piece = piece_moved
    if is_promotion then
        piece = string.match(move, "=(%S)")
    end
    if not is_white then
        piece = string.lower(piece_moved)
    end

    local target_square = get_target_square(move)
    local from = find_piece(piece_moved, target_square, is_white, is_capture, move)
    set_board_square(target_square, piece)
    set_board_square(from, ".")

    -- ente passente
    if piece_moved:lower() == "p" and target_square == en_passant and is_capture then
        print("ente passente")
        local pawn_square = nil
        if is_white then
            pawn_square = string.sub(target_square, 1, 1) .. 5
        else
            pawn_square = string.sub(target_square, 1, 1) .. 4
        end
        set_board_square(pawn_square, ".")
    end
    if piece_moved:lower() == "p" then
        en_passant = "-"
        if is_white then
            if string.sub(from, 2, 2) == "2" and string.sub(target_square, 2, 2) == "4" then
                local file = string.sub(from, 1, 1)
                local file_num = file_to_number(file)
                if (file_num + 1) <= 8 and board[file_num + 1][4] == "p" then
                    en_passant = file .. 3
                elseif (file_num - 1) >= 1 and board[file_num - 1][4] == "p" then
                    en_passant = file .. 3
                end
            end
        else
            if string.sub(from, 2, 2) == "7" and string.sub(target_square, 2, 2) == "5" then
                local file = string.sub(from, 1, 1)
                local file_num = file_to_number(file)
                if (file_num + 1) <= 8 and board[file_num + 1][5] == "P" then
                    en_passant = file .. 6
                elseif (file_num - 1) >= 1 and board[file_num - 1][5] == "P" then
                    en_passant = file .. 6
                end
            end
        end
    end

    -- casteling rights
    if piece_moved:lower() == "k" then
        if is_white then
            can_white_castle_short = false
            can_white_castle_long = false
        else
            can_black_castle_short = false
            can_black_castle_long = false
        end
    end
    if piece_moved:lower() == "r" then
        if from:sub(1, 1) == "a" then
            if is_white then
                can_white_castle_long = false
            else
                can_black_castle_long = false
            end
        elseif from:sub(1, 1) == "h" then
            if is_white then
                can_white_castle_short = false
            else
                can_black_castle_short = false
            end
        end
    end
    if is_capture then
        if target_square == "a1" then
            can_white_castle_long = false
        elseif target_square == "h1" then
            can_white_castle_short = false
        elseif target_square == "a8" then
            can_black_castle_long = false
        elseif target_square == "h8" then
            can_black_castle_short = false
        end
    end

    -- move count

    half_moves = half_moves + 1
    if piece_moved:lower() == "p" or is_capture then
        half_moves_since_pawn_or_capture = 0
    else
        half_moves_since_pawn_or_capture = half_moves_since_pawn_or_capture + 1
    end
end

find_piece = function(piece_moved, target, is_white, is_capture, move)
    local piece = piece_moved
    if not is_white then
        piece = piece_moved:lower()
    end
    local candidates = {}

    local limit_file = nil
    local limit_rank = nil
    if piece:lower() ~= "p" then
        limit_file = file_to_number(get_disambigious_file(move))
        limit_rank = tonumber(get_disambigious_rank(move))
    end

    for file = limit_file or 1, limit_file or 8 do
        for rank = limit_rank or 1, limit_rank or 8 do
            if board[file][rank] == piece then
                if can_move_to(piece, file, rank, target, is_capture, is_white, move) then
                    table.insert(candidates, { file, rank })
                end
            end
        end
    end

    if #candidates > 1 then
        -- TODO
        print("check pin or something")
    end

    return "" .. number_to_file(candidates[1][1]) .. candidates[1][2]
end

local function can_pawn_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    if from_f ~= file_to_number(move:sub(1, 1)) then
        return false
    end
    if is_capture then
        if is_white then
            return target_r - from_r == 1
        else
            return target_r - from_r == -1
        end
    else
        if is_white then
            if target_r - from_r == 1 then
                return true
            end
            if target_r - from_r == 2 and from_r == 2 and board[from_f][3] == "." then
                return true
            end
            return false
        else
            if target_r - from_r == -1 then
                return true
            end
            if target_r - from_r == -2 and from_r == 7 and board[from_f][6] == "." then
                return true
            end
            return false
        end
    end
end

local function can_knight_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    local x = math.abs(from_f - target_f)
    local y = math.abs(from_r - target_r)
    return (x == 2 and y == 1) or (x == 1 and y == 2)
    -- local directions = { { x = 2, y = 1 }, { x = 2, y = -1 }, { x = -2, y = 1 }, { x = -2, y = -1 }, { x = 1, y = 2 }, { x = 1, y = -2 }, { x = -1, y = 2 }, { x = -1, y = -2 } }
    -- for k, direction in ipairs(directions) do
    --     local f = from_f + direction.x
    --     local r = from_r + direction.y
    --     if f == target_f and r == target_r then
    --         return true
    --     end
    -- end
    -- return false
end

local function can_bishop_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    local x = nil
    local y = nil
    if (target_f - from_f) > 0 then
        x = 1
    else
        x = -1
    end
    if (target_r - from_r) > 0 then
        y = 1
    else
        y = -1
    end
    -- dirty loop
    for i = 1, 8 do
        local current_f = from_f + x * i
        local current_r = from_r + y * i
        if current_f > 8 or current_f < 1 or current_r > 8 or current_r < 1 then
            return false
        end
        if current_f == target_f and current_r == target_r then
            return true
        end
        if board[current_f][current_r] ~= "." then
            return false
        end
    end
    return false
end

local function can_rook_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    if not ((from_f == target_f) or (from_r == target_r)) then
        return false
    end
    local x = nil
    local y = nil
    if from_f == target_f then
        x = 0
        if (target_r - from_r) > 0 then
            y = 1
        else
            y = -1
        end
    else
        y = 0
        if (target_f - from_f) > 0 then
            x = 1
        else
            x = -1
        end
    end
    -- dirty loop
    for i = 1, 8 do
        local current_f = from_f + x * i
        local current_r = from_r + y * i
        if current_f > 8 or current_f < 1 or current_r > 8 or current_r < 1 then
            return false
        end
        if current_f == target_f and current_r == target_r then
            return true
        end
        if board[current_f][current_r] ~= "." then
            return false
        end
    end
    return false
end

local function can_queen_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    return can_bishop_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move) or
        can_rook_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
end

local function can_king_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    -- this should work if pgn is valid, then the it will be only piece
    return true
end

can_move_to = function(piece, from_f, from_r, target, is_capture, is_white, move)
    local target_f = file_to_number(target:sub(1, 1))
    local target_r = tonumber(target:sub(2, 2))
    if piece:lower() == "p" then
        return can_pawn_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    elseif piece:lower() == "n" then
        return can_knight_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    elseif piece:lower() == "b" then
        return can_bishop_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    elseif piece:lower() == "r" then
        return can_rook_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    elseif piece:lower() == "q" then
        return can_queen_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    elseif piece:lower() == "k" then
        return can_king_move(piece, from_f, from_r, target_f, target_r, is_capture, is_white, move)
    end
end

function get_disambigious_file(move)
    return string.match(move, "[KQRBN]?([a-h]?)%d?x?%a%d")
end

function get_disambigious_rank(move)
    return string.match(move, "[KQRBN]?[a-h]?(%d?)x?%a%d")
end

get_target_square = function(move)
    return string.match(move, ".-(%a%d)")
end

set_board_square  = function(square, piece)
    local file = file_to_number(string.sub(square, 1, 1))
    local row = tonumber(string.sub(square, 2, 2))
    if row == nil or file == nil then
        print("cannot set piece")
        return
    end
    board[file][row] = piece
end

file_to_number    = function(file)
    if file == "" or file == nil then
        return nil
    end
    local f = string.byte(file) - 96
    return tonumber(f)
end

number_to_file    = function(num)
    return string.char(num + 96)
end

to_fen            = function()
    -- rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
    local fen = ""
    --pieces
    for r = 8, 1, -1 do
        local counter = 0
        for c = 1, 8 do
            if board[c][r] == "." then
                counter = counter + 1
            else
                if counter > 0 then
                    fen = fen .. counter
                end
                fen = fen .. board[c][r]
                counter = 0
            end
        end
        if counter > 0 then
            fen = fen .. counter
        end
        fen = fen .. "/"
    end
    fen = string.sub(fen, 1, -2)

    -- active color
    if half_moves % 2 == 0 then
        fen = fen .. " w"
    else
        fen = fen .. " b"
    end

    -- castling
    local castle = ""
    if can_white_castle_short then
        castle = castle .. "K"
    end
    if can_white_castle_long then
        castle = castle .. "Q"
    end
    if can_black_castle_short then
        castle = castle .. "k"
    end
    if can_black_castle_long then
        castle = castle .. "q"
    end
    if castle == "" then
        fen = fen .. " -"
    else
        fen = fen .. " " .. castle
    end


    -- en passant
    fen = fen .. " " .. en_passant
    -- move clock
    fen = fen .. " " .. half_moves_since_pawn_or_capture
    -- fullmover number
    local full_moves = math.floor((half_moves + 2) / 2)
    fen = fen .. " " .. full_moves
    -- print(vim.inspect(board))
    return (fen)
end

return M
