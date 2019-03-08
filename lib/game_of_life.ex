defmodule GameOfLife do
  use Application

  def start(_type, _args) do
    {:ok, pid} =
      World.Supervisor.start_link([])
  end
end
