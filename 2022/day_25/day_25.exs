defmodule FullOfHotAir do
  @base 5

  defp convert_from_snafu(input) do
    input
    |> String.split("", trim: true)
    |> then(fn digits ->
      places =
        0..(length(digits) - 1)
        |> Enum.reverse()
        |> Enum.map(&Integer.pow(@base, &1))

      digits
      |> Enum.with_index()
      |> Enum.reduce(0, fn {digit, index}, value ->
        case digit do
          "2" -> 2 * Enum.at(places, index)
          "1" -> Enum.at(places, index)
          "0" -> 0
          "-" -> -1 * Enum.at(places, index)
          "=" -> -2 * Enum.at(places, index)
        end
        |> Kernel.+(value)
      end)
    end)
  end

  defp convert_to_snafu(input) do
    input
    |> Integer.digits(@base)
    |> Enum.reverse()
    |> Enum.map_reduce(0, fn digit, carry ->
      (digit + carry)
      |> Kernel.rem(@base)
      |> case do
        4 -> {"-", 1}
        3 -> {"=", 1}
        0 -> if carry == 0, do: {"0", 0}, else: {"0", 1}
        num -> {Integer.to_string(num), 0}
      end
    end)
    |> then(fn {digits, carry} ->
      digits
      |> Enum.reverse()
      |> then(
        &cond do
          carry != 0 -> [carry | &1]
          true -> &1
        end
      )
      |> Enum.join()
    end)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&convert_from_snafu/1)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.sum()
    |> convert_to_snafu()
  end
end

input = File.read!("input.txt")

FullOfHotAir.part_1(input)
