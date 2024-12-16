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
            [{:noop}, {:addx, String.to_integer(value)}]
        end)
    )
    |> List.flatten()
  end

  defp construct_cycles(signals) do
    # offset by one
    [{:noop} | signals]
    |> Enum.scan(
      @initial,
      &case &1 do
        {:noop} -> &2
        {:addx, value} -> &2 + value
      end
    )
  end

  def part_1(input) do
    input
    |> parse_input()
    |> construct_cycles()
    |> Enum.with_index(&{&2 + 1, &1})
    |> Enum.slice(19..-1//1)
    |> Enum.take_every(40)
    |> Enum.reduce(0, &(elem(&1, 0) * elem(&1, 1) + &2))
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    IO.puts("part_2")

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
          true -> output <> " "
        end
      end)
    )
    # remove the extra noop offset we'd added at the start
    |> Enum.drop(-1)
    |> Enum.map(&IO.puts(&1))
  end
end

input = File.read!("input.txt")

CathodeRayTube.part_1(input)
CathodeRayTube.part_2(input)
