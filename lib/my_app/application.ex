defmodule MyApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Registry.start_link(keys: :unique, name: :my_reg)
    identifiers = ["user_one", "user_two", "user_three"]
    values = %{
      :a => ["a0", "a1", "a2"],
      :b => ["b0", "b1", "b2"]
    }

    children = [
      Supervisor.child_spec({MyProducer, {:a, identifiers, values}}, id: :worker_1),
      Supervisor.child_spec({MyProducer, {:b, identifiers, values}}, id: :worker_2),
      Supervisor.child_spec(MyConsumer, id: :consumer_1),
      #Supervisor.child_spec({MyConsumer, :b}, id: :consumer_2)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
