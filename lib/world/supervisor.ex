defmodule World.Supervisor do
  use Supervisor

  def start(_type, _args) do
    World.Supervisor.start_link([])
  end

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(World, []),
      supervisor(Cell.Supervisor, []),
      supervisor(Registry, [:unique, Cell.Registry])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
