local parser = require("chess-viewer.pgn_to_fen")

describe("PGN to FEN", function()
    it("should output starting board", function()
        local pgn = ""
        local expected_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        local result = parser.pgn_to_fen(pgn)
        assert.are.equal(expected_fen, result)
    end)
    -- promotion
    -- row disambigious move
    -- file disambigiou move
    -- double disambigious moves
    -- 2 candidated but pinned
    -- en passant
    -- castle rights
end
)
