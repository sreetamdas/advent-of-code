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

  def part_1(input) do
    {map, {max_x, max_y}} = parse_input(input)

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
    |> IO.inspect(label: "part_2")
  end

  defp get_all_antinodes(coords, bounds, dir \\ :both)
  defp get_all_antinodes({first, nil}, _, _), do: [first]
  defp get_all_antinodes({nil, second}, _, _), do: [second]

  defp get_all_antinodes({{x, y}, {i, j}}, {max_x, max_y} = bounds, dir) do
    dx = x - i
    dy = y - j

    first = {x + dx, y + dy}
    second = {i - dx, j - dy}

    [first, second]
    |> Enum.map(fn
      {nx, ny} when nx > max_x or ny > max_y or nx < 0 or ny < 0 ->
        nil

      x ->
        x
    end)
    |> then(fn [f, s] ->
      case dir do
        :pre ->
          Enum.concat([get_all_antinodes({f, {x, y}}, bounds, :pre), [f, {x, y}, {i, j}, s]])

        :post ->
          Enum.concat([[f, {x, y}, {i, j}, s], get_all_antinodes({{i, j}, s}, bounds, :post)])

        _ ->
          Enum.concat([
            get_all_antinodes({f, {x, y}}, bounds, :pre),
            [f, {x, y}, {i, j}, s],
            get_all_antinodes({{i, j}, s}, bounds, :post)
          ])
      end
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  def part_2(input) do
    {map, bounds} = parse_input(input)

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
      |> Enum.map(fn coords ->
        get_all_antinodes(coords, bounds)
      end)
      |> Enum.map(&Enum.uniq/1)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.map(fn x -> {x, freq} end)
    end)
    |> List.flatten()
    |> Enum.uniq_by(fn {pos, _} -> pos end)
    |> Enum.sort_by(fn {{x, _}, _} -> x end)
    |> length()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input_08.txt")
ResonantCollinearity.part_1(input)
ResonantCollinearity.part_2(input)
