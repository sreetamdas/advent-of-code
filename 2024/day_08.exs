defmodule ResonantCollinearity do
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "", trim: true))
    |> then(fn grid ->
      grid
      |> Enum.with_index()
      |> Enum.map(fn {row, r} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {col, c} ->
          {{r, c}, col}
        end)
      end)
    end)
    |> List.flatten()
    |> Map.new()
    |> then(fn map ->
      {bounds, _} = Enum.max_by(map, fn {{x, y}, _} -> x * y end)

      {map, bounds}
    end)
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- list -- [elem], do: [elem, rest])

  def part_1(input) do
    {map, {max_x, max_y}} =
      input
      |> parse_input()

    map
    |> Map.reject(fn {_key, node} -> node == "." end)
    |> Map.to_list()
    |> Enum.group_by(fn {_, freq} -> freq end, fn {pos, _} -> pos end)
    |> Map.to_list()
    |> Enum.map(fn {freq, pos_list} ->
      for(pos <- pos_list, other <- pos_list -- [pos], do: {pos, other})
      |> Enum.map(fn {{x, y}, {i, j}} = orig ->
        cond do
          x > i -> {{i, j}, {x, y}}
          true -> orig
        end
      end)
      |> Enum.uniq()
      |> Enum.map(fn {{x, y}, {i, j}} ->
        dx = x - i
        dy = y - j

        {{x + dx, y + dy}, {x, y}, {i, j}, {i - dx, j - dy}}
      end)
      |> Enum.map(fn {first, _, _, second} -> [{first, freq}, {second, freq}] end)
    end)
    |> List.flatten()
    |> Enum.reject(fn {{x, y}, _} -> x > max_x or y > max_y or x < 0 or y < 0 end)
    |> Enum.uniq_by(fn {pos, _} -> pos end)
    |> Enum.sort_by(fn {{x, _}, _} -> x end)
    |> length()
  end
end

input = Kino.Input.read(input_raw)
puzzle_input = Kino.Input.read(puzzle_input_raw)
# ResonantCollinearity.part_1(input)
ResonantCollinearity.part_1(puzzle_input)
# ResonantCollinearity.part_2(input)
