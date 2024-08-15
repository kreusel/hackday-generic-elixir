defmodule MyProducer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @one_second 1000

  def init(args) do
    Process.send_after(self(), :tick, @one_second)
    {:ok, args}
  end

  def handle_info(:tick, args) do
    {topic, identifiers, values} = args

    [new_key] = Enum.take_random(identifiers, 1)
    [new_value] = Enum.take_random(values[topic], 1)
    MyConsumer.send_me_a_msg(topic, {new_key, new_value})

    next_wait_time = trunc(2000 + :rand.uniform() * 1000)
    Process.send_after(self(), :tick, next_wait_time)
    {:noreply, args}
  end
end

defmodule MyConsumer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: {:via, Registry, {:my_reg, :recv}})
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  def send_me_a_msg(topic, msg) do
    [{pid, _}] = Registry.lookup(:my_reg, :recv)
    GenServer.call(pid, {:collector, topic, msg})
  end

  @impl true
  def handle_call({:collector, topic, {id, new_value}}, _from, state) do
    new_state = Map.update(state, id, %{topic => new_value}, &Map.put(&1, topic, new_value))

    updated_id = new_state[id]
    case Enum.sort(Map.keys(updated_id)) do
      [:a, :b] -> IO.inspect("User with id #{id} complete: #{Map.values(updated_id)}") #%{id => updated_id}
      _ -> :nothing
    end

    {:reply, nil, new_state}
  end
end
