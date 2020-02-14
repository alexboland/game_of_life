# Elixir Game of Life

Run it in IEX and all that jazz, then you can do the following commands in the console:

Cell.create_cell({x, y}) creates a cell at those coordinates

World.tick() advances the world one tick and sends a message to any connected clients

World.run() runs ticks regularly for a long period of time and sends those messages

The port to connect to right now is 4000.
