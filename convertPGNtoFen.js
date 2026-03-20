#!/usr/bin/env node

const { Chess } = require('chess.js');

let input = '';

process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    try {
        const chess = new Chess();
        chess.loadPgn(input);
        console.log(chess.fen());
    } catch (err) {
        console.error('Error:', err.message);
        process.exit(1);
    }
});
