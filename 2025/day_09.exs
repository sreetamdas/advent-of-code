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

  def area({first, second}), do: area(first, second)
  def area([x, y], [a, b]), do: area({x, y}, {a, b})

  def area({x, y}, {a, b}) do
    [[a, x], [b, y]]
    |> Enum.map(fn coord -> Enum.sort(coord, :desc) |> then(fn [i, j] -> i - j + 1 end) end)
    |> Enum.product()
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
      parsed_reds
      |> Enum.with_index()
      |> Enum.flat_map(fn {red_pos, index} ->
        parsed_reds
        |> Enum.slice((index + 1)..-1//1)
        |> Enum.map(fn other_red ->
          [red_pos, other_red]
        end)
      end)
      |> Enum.map(fn [a, b] = tiles -> {tiles, area(a, b)} end)
      |> Enum.sort_by(fn {_, area} -> area end, :desc)
      |> Enum.reduce_while(nil, fn {tiles = [[a, b] = first, [x, y] = second], area}, _ ->
        [third, fourth] = [[a, y], [x, b]]

        all_four = [first, third, second, fourth]

        cond do
          Enum.all?(all_four, &in_polygon(parsed_reds, &1)) ->
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

              Enum.all?(all_four_edges, &in_polygon(parsed_reds, &1))
            end)
            |> case do
              true -> {:halt, area}
              false -> {:cont, tiles}
            end

          true ->
            {:cont, tiles}
        end
      end)
    end)
    |> tap(fn _ -> :ets.delete(:aoc_2025_day_09) end)
  end
end
