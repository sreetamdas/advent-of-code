defmodule ParabolicReflectorDish do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp bubble_left(input) do
    input
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(fn row ->
      row
      |> Enum.with_index()
      |> Enum.reduce({[], -1}, fn {spot, index}, {row, rock_pos} ->
        case spot do
          "#" ->
            {["#" | row], index}

          "." ->
            {["." | row], rock_pos}

          "O" ->
            # rock rolls to rock_pos + 1
            row
            |> Enum.reverse()
            |> List.insert_at(rock_pos + 1, "O")
            |> Enum.reverse()
            |> then(&{&1, rock_pos + 1})
        end
      end)
      |> then(fn {row, _} -> row end)
    end)
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.reverse()
  end

  def rotate_left(input) do
    input
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(&Enum.reverse/1)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> bubble_left()
    |> Enum.reverse()
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(fn row ->
      row
      |> Enum.with_index(1)
      |> Enum.reduce(0, fn
        {"O", pos}, sum -> sum + pos
        {_, _}, sum -> sum
      end)
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  defp get_cached_1B_index?(current_cycle_index, matched_index) do
    next_match_index =
      rem(1_000_000_000 - matched_index, current_cycle_index - matched_index) +
        current_cycle_index

    current_cycle_index == next_match_index
  end

  def part_2(input) do
    parsed_input = parse_input(input)

    1..1000
    |> Enum.reduce_while(parsed_input, fn current_cycle_index, rotated_after_cycle ->
      case Process.get(rotated_after_cycle) do
        nil ->
          rotated =
            1..4
            |> Enum.reduce(rotated_after_cycle, fn _, rotated_each_dir ->
              rotated_each_dir
              |> bubble_left()
              |> rotate_left()
            end)

          Process.put(rotated_after_cycle, {rotated, current_cycle_index})

          {:cont, rotated}

        {cached, matched_index} ->
          cond do
            get_cached_1B_index?(current_cycle_index, matched_index) ->
              {:halt, cached}

            true ->
              {:cont, cached}
          end
      end
    end)
    # rotate to get weights
    |> rotate_left()
    |> Enum.map(fn row ->
      row
      |> Enum.with_index(1)
      |> Enum.reduce(0, fn
        {"O", pos}, sum -> sum + pos
        {_, _}, sum -> sum
      end)
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

ParabolicReflectorDish.part_1(input)
ParabolicReflectorDish.part_2(input)
