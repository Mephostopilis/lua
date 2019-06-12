
local vector = require "chestnut.vector"

local function make_pgcards( ... )
	-- body
	return {
		opcode = 0,
		gangtype = 0,
		hor = 0,
		width = 0,
		cards = vector(),
		isHoldcard = false,
		isHoldcardInsLast = false
	}
end

return make_pgcards