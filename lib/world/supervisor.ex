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
      supervisor(Registry, [:unique, Cell.Registry], [id: 'cells']),
      supervisor(Registry, [:unique, SocketHandler.Registry], [id: 'sockets']),
      Plug.Cowboy.child_spec(scheme: :http, plug: GameOfLife.Router, options: [
          dispatch: dispatch(),
          port: 4000
      ])
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp dispatch do
  [
    {:_, [
      {"/ws", GameOfLife.SocketHandler, []},
      {:_, Plug.Cowboy.Handler, {GameOfLife.Router, []}}
    ]}
  ]
end

end
