defmodule GameOfLife.SocketHandler do
  @behaviour :cowboy_websocket

    def init(req, state) do
        {:cowboy_websocket, req, %{registry_key: req.path}}
    end

    def websocket_init(state) do
        SocketHandler.Registry
          |> Registry.register(state.registry_key, {})
        {:ok, state}
    end

    def websocket_handle({:text, message}, state) do
        case Poison.decode(message) do
          {:ok, json} ->
            IO.inspect(json)
            websocket_handle({:json, json}, state)
          _ ->
            {:reply, {:text, "invalid format"}, state}
        end
    end

    def websocket_handle({:json, %{cmd: "create_cell", x: x, y: y}}, state) do
        {:reply, {:text, "hello world"}, state}
    end

    def websocket_handle({:json, %{cmd: "destroy_cell", x: x, y: y}}, state) do
        {:reply, {:text, "hello world"}, state}
    end

    def websocket_handle({:json, %{cmd: "start"}}, state) do
        {:reply, {:text, "hello world"}, state}
    end

    def websocket_handle({:json, %{cmd: "pause"}}, state) do
        {:reply, {:text, "hello world"}, state}
    end

    def websocket_handle({:json, %{cmd: "reset"}}, state) do
        {:reply, {:text, "hello world"}, state}
    end

    def websocket_handle({:json, %{cmd: "set_speed", speed: speed}}, state) do
        {:reply, {:text, "hello world"}, state}
    end

    def websocket_handle({:json, _}, state) do
      {:reply, {:text, "invalid command"}, state}
    end

    def websocket_info(info, state) do
      case Poison.encode(info) do
        {:ok, str} -> {:reply, {:text, str}, state}
        {:error, _} -> {:reply, {:text, "something went wrong..."}, state}
      end
    end

    def terminate(_reason, _req, _state) do
        :ok
    end
end
