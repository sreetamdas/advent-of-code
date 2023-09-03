defmodule IWasToldThereWouldBeNoMath do
  def part_1(input) do
    input
    |> String.split(["x", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&get_paper/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> String.split(["x", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&get_ribbon_length/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end

  defp get_paper([l, w, h]) do
    [l * w, w * h, h * l]
    |> then(&(Enum.min(&1) + 2 * Enum.sum(&1)))
  end

  defp get_ribbon_length([l, w, h]) do
    [l + w, w + h, h + l]
    |> then(&(2 * Enum.min(&1) + l * w * h))
  end
end
