defmodule HoofIt do
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(fn {row, r} ->
      row
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {val, c} ->
        {{r, c}, String.to_integer(val)}
      end)
    end)
    |> List.flatten()
    |> then(fn grid_map ->
      zeroes =
        grid_map
        |> Enum.reduce([], fn
          {coords, 0}, starts -> [coords | starts]
          _, starts -> starts
        end)

      {grid_map, Enum.reverse(zeroes)}
    end)
  end

  @dir [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]

  defp get_walkable_trails(grid_map, {x, y}, seen) do
    @dir
    |> Enum.map(fn {i, j} -> {x + i, y + j} end)
    |> Enum.map(fn next_step ->
      grid_map
      |> Map.get(next_step)
      |> then(fn next ->
        cond do
          next == nil ->
            # out of grid
            0

          next == 9 and elem(List.first(seen), 1) == 8 ->
            {1, [{next_step, next} | seen]}

          Enum.member?(seen, next_step) ->
            0

          Enum.empty?(seen) ->
            get_walkable_trails(grid_map, next_step, [{next_step, next}])

          next == elem(List.first(seen), 1) + 1 ->
            get_walkable_trails(grid_map, next_step, [{next_step, next} | seen])

          true ->
            0
        end
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&(&1 == 0))
  end

  def part_1(input) do
    input
    |> parse_input()
    |> then(fn {grid, starts} ->
      grid
      |> Map.new()
      |> then(fn grid_map ->
        starts
        |> Enum.map(fn start_pos ->
          grid_map
          |> get_walkable_trails(start_pos, [{start_pos, 0}])
          |> Enum.map(fn
            {1, steps} ->
              {List.last(steps), List.first(steps)}

            x ->
              x
          end)
          |> Enum.uniq()
          |> Enum.count()
        end)
        |> Enum.sum()
      end)
    end)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> then(fn {grid, starts} ->
      grid
      |> Map.new()
      |> then(fn grid_map ->
        starts
        |> Enum.map(fn start_pos ->
          grid_map
          |> get_walkable_trails(start_pos, [{start_pos, 0}])
          |> Enum.map(fn
            {1, steps} ->
              steps

            x ->
              x
          end)
          |> Enum.uniq()
          |> Enum.count()
        end)
        |> Enum.sum()
      end)
    end)
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input_10.txt")
HoofIt.part_1(input)
HoofIt.part_2(input)

# Benchee
# ##### With input puzzle #####
# Name             ips        average  deviation         median         99th %
# part_1        396.95        2.52 ms     ±8.16%        2.50 ms        2.79 ms
# part_2        354.61        2.82 ms     ±2.02%        2.82 ms        2.95 ms

# Comparison:
# part_1        396.95
# part_2        354.61 - 1.12x slower +0.30 ms
