defmodule TheFloorWillBeLava do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp print(input) do
    input
    |> Enum.map(fn row ->
      row
      |> Enum.map_join("", fn
        {_, [_ | _]} -> "#"
        _ -> "."
      end)
      |> IO.inspect()
    end)
  end

  defp get_grid_dimensions(grid), do: {length(Enum.at(grid, 0)) - 1, length(grid) - 1}

  defp move(:right), do: {0, 1, :right}
  defp move(:bottom), do: {1, 0, :bottom}
  defp move(:left), do: {0, -1, :left}
  defp move(:top), do: {-1, 0, :top}

  @directions [:right, :bottom, :left, :top]

  defp handle_encounter(obj, direction) do
    spot = if is_tuple(obj), do: elem(obj, 0), else: obj

    # returns step to next spot
    case {spot, direction} do
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
        # IO.inspect(pos, label: "already seen in mark seen")

        grid

      true ->
        current_spot = get_at(grid, pos)

        updated_spot =
          case current_spot do
            {spot, directions} when is_list(directions) -> {spot, [direction | directions]}
            spot when is_bitstring(spot) -> {spot, [direction]}
            _ -> IO.inspect("invariant!!!!!!!!")
          end

        # IO.inspect(updated_spot,
        #   label:
        #     "marking #{if is_tuple(current_spot), do: Tuple.to_list(current_spot) |> List.flatten() |> Enum.join(","), else: current_spot} #{Tuple.to_list(pos) |> Enum.join(",")} dir: #{direction}"
        # )

        grid
        |> Enum.at(x)
        |> List.replace_at(y, updated_spot)
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
        # IO.inspect(pos, label: "out of bounds")
        grid

      already_seen?(grid, pos, direction) ->
        # IO.inspect(pos, label: "already seen")
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

            # IO.inspect(
            #   "at {#{x}, #{y}} new: #{Tuple.to_list(new_pos) |> Enum.join(",")} new_dir: #{new_direction}"
            # )

            updated_grid
            |> walk(new_pos, new_direction)

            # |> dbg()
          end)
        end)
    end
  end

  def part_1(input) do
    input
    |> parse_input()
    |> walk()
    |> print()
    |> Enum.join()
    |> String.graphemes()
    |> Enum.count(&(&1 == "#"))
    |> IO.inspect(label: "part_1")
  end

  # def part_2(input) do
  # end
end

input = File.read!("input.txt")

TheFloorWillBeLava.part_1(input)
# TheFloorWillBeLava.part_2(input)
