defmodule NotQuiteLisp do
  def part_1(input) do
    input
    |> String.codepoints()
    |> Enum.frequencies()
    |> Map.values()
    |> then(fn [open | [close]] -> open - close end)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> String.codepoints()
    |> Enum.with_index(1)
    |> Enum.reduce_while(0, fn {move, index}, floor ->
      case move do
        "(" -> floor + 1
        ")" -> floor - 1
      end
      |> then(
        &cond do
          &1 > -1 ->
            {:cont, &1}

          true ->
            {:halt, index}
        end
      )
    end)
    |> IO.inspect(label: "part_2")
  end
end
