#!/usr/bin/env lua

local function printBoard(board)
	io.write("\n---------\n")
	for i = 1, 9 do
		io.write(board[i] .. (i % 3 ~= 0 and " | " or "\n---------\n"))
	end
	print()
end

local function checkWin(board, player)
	if (board[5] == player) and ((board[1] == player and board[9] == player) or (board[3] == player and board[7] == player)) then
		return true
	end

	for i = 1, 7, 3 do
		if board[i] == player and board[i + 1] == player and board[i + 2] == player then
			return true
		end
	end

	for i = 1, 3 do
		if board[i] == player and board[i + 3] == player and board[i + 6] == player then
			return true
		end
	end

	return false
end

local function boardFull(board)
	for i = 1, 9 do
		if tonumber(board[i]) then
			return false
		end
	end
	return true
end

local function humanMove(board)
	while true do
		io.write("Enter a number: ")
		io.flush()
		local n = tonumber(io.read())
		if n and n < 10 and n > 0 then
			local i
			if n < 4 then
				i = n + 6
			elseif n > 6 then
				i = n - 6
			else
				i = n
			end

			if tonumber(board[i]) then
				board[i] = "U"
				break
			end
			print(n .. " is taken by " .. board[i] .. ". Try another position...")
		else
			print("Invalid input! Try a number between 1 and 9")
		end
	end
end

local function computerMove(board)
	local function oppositeOf(i)
		return i == 1 and 9
				or i == 3 and 7
				or i == 7 and 3
				or i == 9 and 1
				or i == 2 and 8
				or i == 4 and 6
				or i == 6 and 4
				or 2
	end

	local function SelectAnything()
		for j = 1, 9 do
			if tonumber(board[j]) then
				print("Selecting " .. j .. " as a last resort")
				return j
			end
		end
	end

	local i

	if tonumber(board[5]) then
		i = 5
	else
		local r, map, c = math.floor(math.random(1, 4)), { 1, 3, 7, 9 }
		c = board[map[r]]
		if tonumber(c) then
			i = map[r]
		elseif c ~= "C" and tonumber(board[oppositeOf(map[r])]) then
			i = oppositeOf(map[r])
		else
			map = { 2, 4, 6, 8 }
			c = board[map[r]]
			if tonumber(c) then
				i = map[r]
			elseif c ~= "C" and tonumber(board[oppositeOf(map[r])]) then
				i = oppositeOf(map[r])
			else
				i = SelectAnything()
			end
		end
	end

	print("Computer chooses: " .. board[i])
	board[i] = "C"
end

-- Main game loop
local function game()
	-- Initialize the board
	local b = { "7", "8", "9", "4", "5", "6", "1", "2", "3" }

	printBoard(b)

	while true do
		humanMove(b)

		if checkWin(b, "U") then
			print("Congratulations! You win!")
			printBoard(b)
			break
		elseif boardFull(b) then
			print("It's a tie!")
			printBoard(b)
			break
		end

		computerMove(b)

		if checkWin(b, "C") then
			print("Computer wins! Better luck next time.")
			printBoard(b)
			break
		elseif boardFull(b) then
			print("It's a tie!")
			printBoard(b)
			break
		end

		printBoard(b)
	end
end

while true do
	game()
	io.write("Would you like to play again? (y/N) ")
	io.flush()
	if string.upper(io.read()) ~= "Y" then
		break
	end
end
