require './pr_counter'
require './status_board'

pr_counter = PrCounter.new
data = pr_counter.run

status_board = StatusBoard.new
status_board.send data
