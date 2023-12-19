defmodule ClumsyCrucible do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn row -> String.graphemes(row) |> Enum.map(&String.to_integer/1) end)
  end

  @directions [:right, :bottom, :left, :top]

  defp move(:right), do: {0, 1, :right}
  defp move(:bottom), do: {1, 0, :bottom}
  defp move(:left), do: {0, -1, :left}
  defp move(:top), do: {-1, 0, :top}

  defp get_next_dir(nil), do: @directions
  defp get_next_dir(dir) when dir in [:left, :right], do: [:top, :bottom]
  defp get_next_dir(_), do: [:left, :right]

  defp get_at(grid, {x, y}),
    do: if(Enum.min([x, y]) < 0, do: nil, else: grid |> Enum.at(x) |> Enum.at(y))

  defp get_next_blocks(grid, current_pos = {x, y}, current_dir) do
    current_dir
    |> get_next_dir()
    |> Enum.flat_map(fn dir ->
      1..3
      |> Enum.map(fn steps ->
        {diff_x, diff_y, _} =
          dir
          |> move()
          |> then(fn {x, y, dir} ->
            {x * steps, y * steps, dir}
          end)

        new_pos = {x + diff_x, y + diff_y}

        grid
        |> get_at(new_pos)
        |> then(&{&1, new_pos, dir})
      end)
      |> Enum.reject(fn {val, _, _} -> is_nil(val) end)
    end)
  end

  defp mark_seen(map, tile) do
    map
    |> Map.update!(:seen, &MapSet.put(&1, tile))
  end

  defp get_next_tile(map, current_dir) do
    {%{seen: seen}, nodes} = Map.split(map, [:seen])

    nodes
    |> Map.keys()
    |> Enum.reject(&MapSet.member?(seen, &1))
    |> then(fn unseen_tiles ->
      nodes
      |> Map.take(unseen_tiles)
      |> Map.to_list()
      |> Enum.reduce({nil, nil, nil}, fn {tile, {heat_loss, _prev, dir}},
                                         {_min_tile, min_heat_loss, _next_dir} = acc ->
        cond do
          heat_loss < min_heat_loss and dir in get_next_dir(current_dir) -> {tile, heat_loss, dir}
          true -> acc
        end
      end)
    end)
  end

  defp walk(grid, current \\ {0, {0, 0}, :right}, map \\ %{seen: MapSet.new()})
  defp walk(grid, {x, x}, map) when x == length(grid), do: map

  defp walk(grid, {current_heat_loss, current_tile, current_dir}, map) do
    grid
    |> get_next_blocks(current_tile, current_dir)
    |> Enum.reduce(map, fn {heat_loss, block_pos, to_tile_dir}, updated_map ->
      # current heat loss to block_pos
      next_block_heat_loss =
        Map.get(updated_map, block_pos, {nil, {nil, nil}})

      estimated_total_heat_loss = current_heat_loss + heat_loss

      # total loss to block_pos
      cond do
        estimated_total_heat_loss < next_block_heat_loss ->
          Map.put(updated_map, block_pos, {estimated_total_heat_loss, current_tile, to_tile_dir})

        true ->
          updated_map
      end
    end)
    |> mark_seen(current_tile)
    |> then(fn updated_map ->
      updated_map
      |> get_next_tile(current_dir)
      |> then(fn {next_tile, next_heat_loss, next_dir} ->
        IO.inspect({next_tile, next_heat_loss, next_dir}, label: "next")

        walk(grid, {current_heat_loss + next_heat_loss, next_tile, next_dir}, updated_map)
      end)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> walk()
  end
end

input = Kino.Input.read(input_raw)

ClumsyCrucible.part_1(input)
# ClumsyCrucible.part_2(input)
