defmodule RedNosedReports do
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def safe_or_remove_at(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Enum.map(fn {[x, y], i} -> {[x - y, x > y], i} end)
    |> then(fn [{[_, is_decreasing], _} | _] = chunks ->
      chunks
      |> Enum.reduce_while(nil, fn {[diff, _], i}, x ->
        cond do
          is_decreasing ->
            diff > 0 and diff <= 3

          true ->
            diff < 0 and diff >= -3
        end
        |> case do
          false ->
            {:halt, i}

          _ ->
            {:cont, x}
        end
      end)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&safe_or_remove_at/1)
    |> Enum.count(&is_nil/1)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn report ->
      report
      |> safe_or_remove_at()
      |> case do
        nil ->
          true

        i ->
          -1..1
          |> Enum.map(fn j ->
            report
            |> List.delete_at(i + j)
            |> safe_or_remove_at()
          end)
          |> Enum.any?(&is_nil/1)
      end
    end)
    |> Enum.count(& &1)
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

RedNosedReports.part_1(input)
RedNosedReports.part_2(input)
