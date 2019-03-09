defmodule World do
  use GenServer

  def init(args) do
    {:ok, args}
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def tick do
    GenServer.call(__MODULE__, {:tick})
  end

  def run do
    1..100000
      |> Enum.map(fn
        n -> World.tick()
          :timer.sleep(500)
      end)
  end

  def handle_call({:tick}, from, _state) do
    ticks = Cell.Supervisor.children
      |> Enum.map(fn pid -> Task.async(fn -> Cell.tick(pid) end) end)
      |> Enum.map(&Task.await/1)

    deaths = dying_cells(ticks)

    births = new_cells(ticks)

    death_tasks = deaths
      |> Enum.map(&Cell.lookup/1)
      |> Enum.map(fn cell -> fn -> Cell.die(cell) end end)

    birth_tasks = births
      |> Enum.map(fn pos -> fn -> Cell.create_cell(pos) end end)

    death_tasks ++ birth_tasks
      |> Enum.map(fn task -> Task.async(task) end)
      |> Enum.map(&Task.await/1)


    births_json = Enum.map(births, fn b -> %{x: elem(b, 0), y: elem(b, 1)} end)
    deaths_json = Enum.map(deaths, fn d -> %{x: elem(d, 0), y: elem(d, 1)} end)
    info = %{births: births_json, deaths: deaths_json}


    Registry.dispatch(SocketHandler.Registry, "/ws", fn entries ->
      for {pid, _} <- entries, do: send(pid, info)
    end)

    {:reply, info, []}
  end

  defp dying_cells(cells) do
    Enum.filter(cells, &match?({_, _, false}, &1))
    |> Enum.map(fn {pos, _, _} -> pos end)
  end

  defp new_cells(cells) do
    Enum.flat_map(cells, fn {_, nbrs, _} -> nbrs end)
    |> Enum.group_by(fn x -> x end)
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.filter(fn {_k, v} -> v == 3 end)
    |> Enum.map(fn {k, v} -> k end)
  end
end
