defmodule GrovePositioningSystem do
  def part_1(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> process_mixing()
    |> get_coordinates()
    |> IO.inspect(label: "part_1")
  end

  @decryption_key 811_589_153
  def part_2(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Kernel.*(&1, @decryption_key))
    |> Enum.with_index()
    |> then(fn original_list ->
      1..10
      |> Enum.reduce(original_list, fn _index, mixed_list ->
        process_mixing(mixed_list, original_list)
      end)
    end)
    |> get_coordinates()
    |> IO.inspect(label: "part_2")
  end

  defp process_mixing(list, initial_list \\ nil) do
    original_list = if !is_nil(initial_list), do: initial_list, else: list

    original_list
    |> Enum.reduce(list, fn {value, index}, updated_list ->
      current_index =
        Enum.find_index(updated_list, fn
          {^value, ^index} -> true
          _ -> false
        end)

      updated_index =
        case rem(current_index + value, length(list) - 1) do
          0 when current_index !== 0 -> -1
          x when x < 0 -> x - 1
          other -> other
        end

      Enum.slide(updated_list, current_index, updated_index)
    end)
  end

  defp get_coordinates(list) do
    zero_position =
      Enum.find_index(list, fn
        {0, _} -> true
        _ -> false
      end)

    first = get_after(list, 1000, zero_position)
    second = get_after(list, 2000, zero_position)
    third = get_after(list, 3000, zero_position)

    first + second + third
  end

  defp get_after(input, positions, pivot) do
    input
    |> Enum.at(rem(pivot + positions, length(input)))
    |> elem(0)
  end
end

input = File.read!("input.txt")

GrovePositioningSystem.part_1(input)
GrovePositioningSystem.part_2(input)
