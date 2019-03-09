
defmodule GameOfLife do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: GameOfLife.Router,
        options: [
          dispatch: dispatch(),
          port: 4000
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: SocketManager.Registry
      ),
      supervisor(World.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: GameOfLife.Application]
    Supervisor.init(children, opts)
  end

  defp dispatch do
    [
      {:_,
        [
          {"/ws/[...]", MyWebsocketApp.SocketHandler, []},
          {:_, Plug.Cowboy.Handler, {MyWebsocketApp.Router, []}}
        ]
      }
    ]
  end
end
