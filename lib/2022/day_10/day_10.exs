defmodule CathodeRayTube do
  @initial 1

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(
      &(String.split(&1, " ")
        |> case do
          ["noop"] ->
            {:noop}

          ["addx", value] ->
            {:addx, String.to_integer(value)}
        end)
    )
  end

  defp repeat_signal(signal) do
    signal
    |> case do
      {:noop} ->
        signal

      {:addx, value} ->
        [{:addx_pause}, {:addx, value}]
    end
  end

  defp construct_cycles(signals) do
    cycles =
      signals
      |> Enum.map(&repeat_signal/1)
      |> List.flatten()

    Enum.scan([{:noop} | cycles], @initial, fn signal, acc_value ->
      signal
      |> case do
        {:noop} -> acc_value
        {:addx_pause} -> acc_value
        {:addx, value} -> acc_value + value
      end
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> construct_cycles()
    |> Enum.with_index(&{&2 + 1, &1})
    |> Enum.slice(19..-1//1)
    |> Enum.take_every(40)
    |> Enum.reduce(0, fn {index, value}, sum -> sum + value * index end)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> construct_cycles()
    |> Enum.chunk_every(40)
    |> Enum.map(fn row ->
      row |> Enum.with_index(&{&2, &1})
    end)
    |> Enum.map(
      &Enum.reduce(&1, "", fn {position, register}, output ->
        cond do
          position in (register - 1)..(register + 1) -> output <> "#"
          true -> output <> "."
        end
      end)
    )
    # remove the extra noop we'd added at the start
    |> Enum.drop(-1)
    |> Enum.map(&IO.puts(&1))
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

CathodeRayTube.part_1(input)
CathodeRayTube.part_2(input)
