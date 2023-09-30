defmodule DistressSignal do
  defp parse_input(input) do
    input
    |> String.split(["\n"], trim: true)
    |> Enum.map(&Code.eval_string/1)
    |> Enum.map(&elem(&1, 0))
  end

  defp compare?([left, right]) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> true
      left > right -> false
      true -> :cont
    end
  end

  defp compare?([[left_head | left_rest], [right_head | right_rest]]) do
    compare?([left_head, right_head])
    |> case do
      :cont -> compare?([left_rest, right_rest])
      result -> result
    end
  end

  defp compare?([[], [_ | _]]), do: true
  defp compare?([[_ | _], []]), do: false
  defp compare?([[], []]), do: :cont

  defp compare?([left, right]) when is_list(left) and is_integer(right),
    do: compare?([left, [right]])

  defp compare?([left, right]) when is_integer(left) and is_list(right),
    do: compare?([[left], right])

  defp solve(input) do
    input
    |> Enum.with_index(1)
    |> Enum.map(fn {pair, index} ->
      pair
      |> compare?()
      |> then(&{index, &1})
    end)
  end

  defp get_keys(input) do
    p1 = Enum.find_index(input, &(&1 == [[2]])) + 1
    p2 = Enum.find_index(input, &(&1 == [[6]])) + 1
    p1 * p2
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.chunk_every(2)
    |> solve()
    |> Enum.filter(fn {_, order} -> order end)
    |> Enum.map(fn {index, _} -> index end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.concat([[[2]], [[6]]])
    |> Enum.sort(&compare?([&1, &2]))
    |> get_keys()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

DistressSignal.part_1(input)
DistressSignal.part_2(input)
