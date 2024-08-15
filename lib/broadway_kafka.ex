defmodule Broadway_Kafka do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayKafka.Producer,
           [
             hosts: [localhost: 9092],
             group_id: "group_1",
             topics: ["test_a", "test_b"]
           ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 10
        ]
      ],
      batchers: [
        default: [
          batch_size: 100,
          batch_timeout: 200,
          concurrency: 10
        ]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    #IO.inspect(message)

    topic = case message.metadata.topic do
      "test_a" -> :a
      "test_b" -> :b
    end

    [new_key, new_value] = String.split(message.data, ",")

    #IO.puts(" #{topic} #{new_key} #{new_value}")
    MyConsumer.send_me_a_msg(topic, {new_key, new_value})
    message
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    list = messages |> Enum.map(fn e -> e.data end)
    #IO.inspect(list, label: "Got batch")
    messages
  end
end
