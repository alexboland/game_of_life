defmodule Cell do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link(position) do
    GenServer.start_link(__MODULE__, position, name: {
      :via, Registry, {Cell.Registry, position}
    })
  end

  def tick(process) do
    GenServer.call(process, {:tick})
  end

  def die(process) do
    process && Supervisor.terminate_child(Cell.Supervisor, process)
  end

  def handle_call({:tick}, _from, position) do
    nbrs = neighbors(position)
    dead_nbrs = Enum.filter(nbrs, &match?({_x, _y, nil}, &1))
      |> Enum.map(fn {x, y, nil} -> {x, y} end)
    nbr_count = Enum.reject(nbrs, &match?({_x, _y, nil}, &1))
      |> Enum.count
    will_survive = nbr_count > 1 && nbr_count < 4
    {:reply, {position, dead_nbrs, will_survive}, position}
  end

  defp neighbors(position) do
    nbr_coords = for x <- [-1, 0, 1], y <- [-1, 0, 1], do: {x, y}

    nbr_coords
    |> Enum.reject(fn coords -> coords == {0, 0} end)
    |> Enum.map(fn {dx, dy} -> {elem(position, 0) + dx, elem(position, 1) + dy} end)
    |> Enum.map(fn {x, y} -> {x, y, lookup({x, y} )} end)
  end

  def lookup(position) do
    Cell.Registry
    |> Registry.lookup(position)
    |> Enum.map(fn
        {pid, _valid} -> pid
        nil -> nil
      end)
    |> Enum.filter(&Process.alive?/1)
    |> List.first
  end

  def create_cell(position) do
    Supervisor.start_child(Cell.Supervisor, [position])
  end
end
