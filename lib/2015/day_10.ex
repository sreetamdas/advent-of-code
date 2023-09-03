defmodule ElvesLookElvesSay do
  def part_1(input) do
    input
    |> String.to_integer()
    |> Integer.digits()
    |> solve(40)
    |> length()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> String.to_integer()
    |> Integer.digits()
    |> solve(50)
    |> length()
    |> IO.inspect(label: "part_2")
  end

  defp solve(number_list, times) do
    Enum.reduce(1..times, number_list, fn _, list ->
      process(list)
    end)
  end

  defp process(number_list) do
    number_list
    |> Enum.reduce([], &count_and_say/2)
    |> Enum.reverse()
    |> Enum.flat_map(fn [number | _] = list ->
      [length(list), number]
    end)
  end

  defp count_and_say(number, list) do
    current_list = List.first(list, [nil])

    current_list
    |> List.first()
    |> then(fn current_digit ->
      case current_digit do
        # same digit as current
        ^number ->
          list
          |> List.delete_at(0)
          |> then(&[[number | current_list] | &1])

        # new digit
        _ ->
          [[number] | list]
      end
    end)
  end
end
