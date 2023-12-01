defmodule Trebuchet do
  @digits %{
    "zero" => "0",
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
    "0" => "0",
    "1" => "1",
    "2" => "2",
    "3" => "3",
    "4" => "4",
    "5" => "5",
    "6" => "6",
    "7" => "7",
    "8" => "8",
    "9" => "9"
  }

  def replace_string(input, reversed \\ false) do
    Map.keys(@digits)
    |> Enum.map_join("|", &if(reversed, do: String.reverse(&1), else: &1))
    |> Regex.compile!()
    |> Regex.replace(
      input,
      fn num_word ->
        @digits
        |> Map.get(if reversed, do: String.reverse(num_word), else: num_word)
        |> then(&"#{&1}#{num_word}")
      end,
      global: false
    )
    |> String.reverse()
    |> then(&if reversed, do: &1, else: replace_string(&1, true))
  end

  def get_calibration_value(input) do
    input
    |> Enum.map(fn string ->
      string
      |> String.graphemes()
      |> Enum.flat_map(fn char ->
        char
        |> Integer.parse()
        |> case do
          :error -> []
          {num, _} -> [num]
        end
      end)
    end)
    |> Enum.map(fn list ->
      [first | _] = list
      [last | _] = Enum.reverse(list)

      Integer.undigits([first, last])
    end)
    |> Enum.sum()
  end

  def part_1(input) do
    input
    |> String.split("\n")
    |> get_calibration_value()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&replace_string/1)
    |> get_calibration_value()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

Trebuchet.part_1(input)
Trebuchet.part_2(input)
