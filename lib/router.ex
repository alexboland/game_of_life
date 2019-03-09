defmodule GameOfLife.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  match _ do
    send_resp(conn, 200, "boop")
  end
end
