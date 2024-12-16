defmodule GuardGallivant do
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
      map
      |> Enum.find(fn {_, v} -> v == "^" end)
      |> then(fn {start, _} ->
        {{max_x, max_y}, _} =
          map
          |> Enum.max_by(fn {{x, y}, _} -> x * y end)

        {map, start, {max_x, max_y}, :up}
      end)
    end)
  end

  defp move(:right), do: {0, 1}
  defp move(:down), do: {1, 0}
  defp move(:left), do: {0, -1}
  defp move(:up), do: {-1, 0}

  defp turn(:right), do: :down
  defp turn(:down), do: :left
  defp turn(:left), do: :up
  defp turn(:up), do: :right

  defp print_grid(grid_map) do
    grid_map
    |> Map.to_list()
    |> Enum.group_by(fn {{x, _}, _} -> x end)
    |> Map.to_list()
    |> Enum.sort_by(fn {i, _} -> i end)
    |> Enum.map(fn {_, row} -> row end)
    |> Enum.map(fn row ->
      row
      |> Enum.sort_by(fn {{_, c}, _} -> c end)
      |> Enum.map(fn {_, x} -> x end)
    end)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def walk(
        {grid_map_init, pos_init, {max_x, max_y} = bounds, dir_init},
        seen_init,
        checking_loop \\ false
      ) do
    Stream.unfold({grid_map_init, pos_init, dir_init, seen_init, 0}, fn
      :halt ->
        nil

      {grid_map, {old_x, old_y} = old_pos, dir, seen, loops} = cycle ->
        dir
        |> move()
        |> then(fn {i, j} ->
          pos = {x, y} = {old_x + i, old_y + j}

          cond do
            x > max_x or y > max_y or x < 0 or y < 0 ->
              {{cycle, :exit}, :halt}

            MapSet.member?(seen, {pos, dir}) ->
              {{true, :loop}, :halt}

            true ->
              grid_map
              |> Map.get_and_update(pos, fn
                "O" -> {:turn, "O"}
                "#" -> {:turn, "#"}
                "." -> {:check_loop, "X"}
                x -> {x, x}
              end)
              |> then(fn
                {:turn, updated_grid_map} ->
                  {cycle,
                   {updated_grid_map, old_pos, turn(dir), MapSet.put(seen, {old_pos, turn(dir)}),
                    loops}}

                {:check_loop, updated_grid_map} ->
                  if !checking_loop do
                    # turn right from old_pos
                    grid_map
                    |> Map.put(pos, "O")
                    |> then(fn new_obstacle_grid_map ->
                      walk({new_obstacle_grid_map, old_pos, bounds, dir}, seen, true)
                    end)
                    |> Enum.to_list()
                    |> Enum.take(-1)
                    |> then(fn [{_, reason}] ->
                      reason
                    end)
                    |> case do
                      :loop ->
                        1

                      _ ->
                        0
                    end
                  else
                    0
                  end
                  |> then(
                    &{cycle, {updated_grid_map, pos, dir, MapSet.put(seen, {pos, dir}), loops + &1}}
                  )

                {_, updated_grid_map} ->
                  {cycle, {updated_grid_map, pos, dir, MapSet.put(seen, {pos, dir}), loops}}
              end)
          end
        end)
    end)
  end

  def solve(input) do
    input
    |> parse_input()
    |> then(fn {_, start, _, _} = parsed_input ->
      walk(parsed_input, MapSet.new([{start, :up}]))
    end)
    |> Enum.to_list()
    |> Enum.take(-1)
    |> then(fn [{{_grid, _final_pos, _dir, seen, loops}, _reason}] ->
      seen
      |> MapSet.to_list()
      |> Enum.uniq_by(fn {pos, _dir} -> pos end)
      |> length()
      |> IO.inspect(label: "part_1")

      IO.inspect(loops, label: "part_2")
    end)
  end
end

input = File.read!("input.txt")

GuardGallivant.solve(input)
