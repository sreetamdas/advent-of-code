defmodule TheFloorWillBeLava do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp mark_energized_tiles(input) do
    input
    |> Enum.map(fn row ->
      row
      |> Enum.map_join("", fn
        {_, [_ | _]} -> "#"
        _ -> "."
      end)
    end)
  end

  defp get_grid_dimensions(grid), do: {length(Enum.at(grid, 0)) - 1, length(grid) - 1}

  defp move(:right), do: {0, 1, :right}
  defp move(:bottom), do: {1, 0, :bottom}
  defp move(:left), do: {0, -1, :left}
  defp move(:top), do: {-1, 0, :top}

  @directions [:right, :bottom, :left, :top]

  defp handle_encounter(obj, direction) do
    tile = if is_tuple(obj), do: elem(obj, 0), else: obj

    case {tile, direction} do
      {".", dir} when dir in @directions ->
        [move(dir)]

      {"|", dir} when dir in [:right, :left] ->
        [move(:top), move(:bottom)]

      {"|", dir} when dir in [:bottom, :top] ->
        [move(dir)]

      {"-", dir} when dir in [:right, :left] ->
        [move(dir)]

      {"-", dir} when dir in [:bottom, :top] ->
        [move(:right), move(:left)]

      {"\\", :right} ->
        [move(:bottom)]

      {"\\", :bottom} ->
        [move(:right)]

      {"\\", :left} ->
        [move(:top)]

      {"\\", :top} ->
        [move(:left)]

      {"/", :right} ->
        [move(:top)]

      {"/", :bottom} ->
        [move(:left)]

      {"/", :left} ->
        [move(:bottom)]

      {"/", :top} ->
        [move(:right)]
    end
  end

  defp get_at(grid, {x, y}), do: grid |> Enum.at(x) |> Enum.at(y)

  defp mark_seen(grid, pos = {x, y}, direction) do
    cond do
      already_seen?(grid, pos, direction) ->
        grid

      true ->
        current_tile = get_at(grid, pos)

        updated_tile =
          case current_tile do
            {tile, directions} when is_list(directions) -> {tile, [direction | directions]}
            tile when is_bitstring(tile) -> {tile, [direction]}
          end

        grid
        |> Enum.at(x)
        |> List.replace_at(y, updated_tile)
        |> then(&List.replace_at(grid, x, &1))
    end
  end

  defp already_seen?(grid, pos, direction) do
    grid
    |> get_at(pos)
    |> case do
      {_obj, directions} -> Enum.member?(directions, direction)
      _ -> false
    end
  end

  defp walk(grid, pos = {x, y} \\ {0, 0}, direction \\ :right) do
    {max_x, max_y} = get_grid_dimensions(grid)

    cond do
      x < 0 or y < 0 or x > max_x or y > max_y ->
        grid

      already_seen?(grid, pos, direction) ->
        grid

      true ->
        grid
        |> mark_seen(pos, direction)
        |> then(fn marked_grid ->
          marked_grid
          |> get_at(pos)
          |> handle_encounter(direction)
          |> Enum.reduce(marked_grid, fn {new_x, new_y, new_direction}, updated_grid ->
            new_pos = {x + new_x, y + new_y}

            updated_grid
            |> walk(new_pos, new_direction)
          end)
        end)
    end
  end

  defp get_all_possible_starting_orientations(grid) do
    grid
    |> get_grid_dimensions()
    |> then(fn {max_x, max_y} ->
      for i <- 0..max_x do
        [{i, 0, :right}, {i, max_y, :left}, {0, i, :bottom}, {max_y, i, :top}]
      end
      |> List.flatten()
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> walk()
    |> mark_energized_tiles()
    |> Enum.join()
    |> String.graphemes()
    |> Enum.count(&(&1 == "#"))
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    parsed_input =
      input
      |> parse_input()

    parsed_input
    |> get_all_possible_starting_orientations()
    |> Enum.map(fn {x, y, dir} ->
      parsed_input
      |> walk({x, y}, dir)
      |> mark_energized_tiles()
      |> Enum.join()
      |> String.graphemes()
      |> Enum.count(&(&1 == "#"))
    end)
    |> Enum.max()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

TheFloorWillBeLava.part_1(input)
TheFloorWillBeLava.part_2(input)
