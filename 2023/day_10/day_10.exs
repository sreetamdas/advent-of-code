defmodule MirageMaintenance do
  defp parse_input(input) do
    grid =
      input
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    grid
    |> List.flatten()
    |> Enum.find_index(&(&1 == "S"))
    |> then(fn index ->
      x = div(index, length(grid))
      y = rem(index, length(grid))

      {grid, {x, y}}
    end)
  end

  @directions [:right, :bottom, :left, :top]

  defp move(:right), do: {0, 1, :right}
  defp move(:bottom), do: {1, 0, :bottom}
  defp move(:left), do: {0, -1, :left}
  defp move(:top), do: {-1, 0, :top}

  defp handle_encounter(obj, direction) do
    tile = if is_tuple(obj), do: elem(obj, 0), else: obj

    case {tile, direction} do
      {"|", dir} when dir in [:bottom, :top] ->
        move(dir)

      {"-", dir} when dir in [:right, :left] ->
        move(dir)

      {"L", :bottom} ->
        move(:right)

      {"L", :left} ->
        move(:top)

      {"J", :bottom} ->
        move(:left)

      {"J", :right} ->
        move(:top)

      {"7", :right} ->
        move(:bottom)

      {"7", :top} ->
        move(:left)

      {"F", :left} ->
        move(:bottom)

      {"F", :top} ->
        move(:right)

      _ ->
        nil
    end
  end

  defp get_at(grid, {x, y}), do: grid |> Enum.at(x) |> Enum.at(y)

  defp mark_seen(grid, pos = {x, y}) do
    cond do
      already_seen?(grid, pos) ->
        grid

      true ->
        current_tile = get_at(grid, pos)

        grid
        |> Enum.at(x)
        |> List.replace_at(y, {current_tile, :seen})
        |> then(&List.replace_at(grid, x, &1))
    end
  end

  defp already_seen?(grid, pos) do
    grid
    |> get_at(pos)
    |> case do
      {_obj, :seen} -> true
      _ -> false
    end
  end

  defp find_starting_nodes(grid, {x, y}) do
    @directions
    |> Enum.map(fn direction ->
      direction
      |> move()
      |> then(fn {new_x, new_y, _} ->
        new_pos = {x + new_x, y + new_y}

        grid
        |> get_at(new_pos)
        |> case do
          "|" when direction in [:bottom, :top] -> true
          "-" when direction in [:right, :left] -> true
          "L" when direction in [:bottom, :left] -> true
          "J" when direction in [:right, :bottom] -> true
          "7" when direction in [:right, :top] -> true
          "F" when direction in [:left, :top] -> true
          _ -> nil
        end
      end)
    end)
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {true, index} ->
        {new_x, new_y, dir} =
          @directions
          |> Enum.at(index)
          |> move()

        [{x + new_x, y + new_y, dir}]

      _ ->
        []
    end)
  end

  defp find_loop({grid, start_pos}) do
    starting_nodes_with_dir =
      grid
      |> mark_seen(start_pos)
      |> find_starting_nodes(start_pos)

    Stream.unfold({grid, starting_nodes_with_dir}, fn
      {_, [{x, y, _}, {x, y, _}]} ->
        nil

      {updated_both_grid, nodes} = cycle ->
        nodes
        |> Enum.map_reduce(updated_both_grid, fn {x, y, dir}, updated_grid ->
          marked_grid =
            updated_grid
            |> mark_seen({x, y})

          marked_grid
          |> get_at({x, y})
          |> handle_encounter(dir)
          |> then(fn {diff_x, diff_y, new_dir} ->
            {{x + diff_x, y + diff_y, new_dir}, marked_grid}
          end)
        end)
        |> then(fn {next_nodes, next_grid} ->
          {cycle, {next_grid, next_nodes}}
        end)
    end)
    |> Enum.to_list()
    |> length()
    |> then(&(&1 + 1))
  end

  def part_1(input) do
    input
    |> parse_input()
    |> find_loop()
    |> IO.inspect(label: "part_1")
  end
end

input = File.read!("input.txt")

MirageMaintenance.part_1(input)
# MirageMaintenance.part_2(input)
