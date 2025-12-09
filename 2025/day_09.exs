defmodule MovieTheater do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def area({first, second} = input) when is_tuple(input), do: area(first, second)
  def area([first, second] = input) when is_list(input), do: area(first, second)
  def area([x, y], [a, b]), do: area({x, y}, {a, b})

  def area({x, y}, {a, b}) do
    [[a, x], [b, y]]
    |> Enum.map(fn coord -> Enum.sort(coord, :desc) |> then(fn [i, j] -> i - j + 1 end) end)
    |> Enum.product()
  end

  def compress_coords(points) do
    points
    |> Enum.zip()
    |> Enum.map(fn coord_list ->
      coord_list
      |> Tuple.to_list()
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.with_index()
      |> Map.new()
    end)
    |> then(fn [x_map, y_map] ->
      Enum.map(points, fn [x, y] ->
        [x_map[x], y_map[y]]
      end)
    end)
  end

  def decompress_coords(compressed_coords, original_coords) do
    original_coords
    |> Enum.zip()
    |> Enum.map(fn coord_list ->
      coord_list
      |> Tuple.to_list()
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.with_index()
      |> Map.new(fn {coord, idx} -> {idx, coord} end)
    end)
    |> then(fn [x_reverse_map, y_reverse_map] ->
      Enum.map(compressed_coords, fn [x_idx, y_idx] ->
        [x_reverse_map[x_idx], y_reverse_map[y_idx]]
      end)
    end)
  end

  defp on_edge?(points, [px, py]) do
    points
    |> Enum.zip(Enum.drop(points, 1) ++ [hd(points)])
    |> Enum.any?(fn {[x1, y1], [x2, y2]} ->
      py <= y1 != py <= y2 and
        px <= x1 != px <= x2 and
        (x2 - x1) * (py - y1) == (px - x1) * (y2 - y1)
    end)
  end

  def in_polygon(points, [px, py] = point) do
    case :ets.lookup(:aoc_2025_day_09, {px, py}) do
      [] ->
        cond do
          point in points ->
            true

          on_edge?(points, point) ->
            true

          true ->
            points
            |> Enum.zip(Enum.drop(points, 1) ++ [hd(points)])
            |> Enum.count(fn {[x1, y1], [x2, y2]} ->
              py < y1 != py < y2 and
                px < (x2 - x1) * (py - y1) / (y2 - y1) + x1
            end)
            |> rem(2) == 1
        end
        |> tap(&:ets.insert(:aoc_2025_day_09, {{px, py}, &1}))

      [{_, val}] ->
        val
    end
  end

  def part_1(input) do
    :ets.new(:aoc_2025_day_09, [:named_table])

    input
    |> parse_input()
    |> then(fn parsed_reds ->
      parsed_reds
      |> Enum.with_index()
      |> Enum.flat_map(fn {red_pos, index} ->
        parsed_reds
        |> Enum.slice((index + 1)..-1//1)
        |> Enum.map(fn other_red ->
          {red_pos, other_red}
        end)
      end)
    end)
    |> Enum.map(&area/1)
    |> Enum.sort(:desc)
    |> List.first()
    |> tap(fn _ -> :ets.delete(:aoc_2025_day_09) end)
  end

  def part_2(input) do
    :ets.new(:aoc_2025_day_09, [:named_table])

    input
    |> parse_input()
    |> then(fn parsed_reds ->
      compressed_coords =
        parsed_reds
        |> compress_coords()

      compressed_coords
      |> Enum.with_index()
      |> Enum.flat_map(fn {red_pos, index} ->
        compressed_coords
        |> Enum.slice((index + 1)..-1//1)
        |> Enum.map(fn other_red ->
          [red_pos, other_red]
        end)
      end)
      |> Enum.map(fn [a, b] = tiles -> {tiles, area(a, b)} end)
      |> Enum.sort_by(fn {_, area} -> area end, :desc)
      |> Enum.reduce_while(nil, fn {tiles = [[a, b] = first, [x, y] = second], _area}, _ ->
        [third, fourth] = [[a, y], [x, b]]

        all_four = [first, third, second, fourth]

        cond do
          Enum.all?(all_four, &in_polygon(compressed_coords, &1)) ->
            all_four
            |> Enum.chunk_every(2, 1, :discard)
            |> Enum.all?(fn [_p1 = [x1, y1], _p2 = [x2, y2]] ->
              all_four_edges =
                cond do
                  x1 == x2 ->
                    [y1, y2]
                    |> Enum.sort()
                    |> then(fn [one, two] ->
                      one..two
                      |> Enum.map(&[x1, &1])
                    end)

                  y1 == y2 ->
                    [x1, x2]
                    |> Enum.sort()
                    |> then(fn [one, two] ->
                      one..two
                      |> Enum.map(&[&1, y1])
                    end)
                end

              Enum.all?(all_four_edges, &in_polygon(compressed_coords, &1))
            end)
            |> case do
              true -> {:halt, tiles}
              false -> {:cont, tiles}
            end

          true ->
            {:cont, tiles}
        end
      end)
      |> decompress_coords(parsed_reds)
      |> area()
    end)
    |> tap(fn _ -> :ets.delete(:aoc_2025_day_09) end)
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1         58.71       17.03 ms    ±13.40%       16.25 ms       24.48 ms
# part_2          3.73      268.09 ms     ±5.44%      264.43 ms      311.90 ms

# Comparison:
# part_1         58.71
# part_2          3.73 - 15.74x slower +251.06 ms

# Memory usage statistics:

# Name      Memory usage
# part_1       0.0590 GB
# part_2         1.70 GB - 28.87x memory usage +1.64 GB
