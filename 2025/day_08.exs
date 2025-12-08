defmodule Playground do
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

  def shortest_path(x, y) do
    Enum.zip_reduce(x, y, 0, fn i, j, sum -> sum + (i - j) ** 2 end)
  end

  defp connect_junction_box(circuits, {point, a}, {other_point, x}) do
    circuits
    |> Enum.with_index()
    |> then(fn circuits_with_index ->
      circuits_with_index
      |> Enum.reduce([], fn {mapset, _} = mapset_with_index, res ->
        cond do
          MapSet.member?(mapset, a) and MapSet.member?(mapset, x) -> {mapset, :already_connected}
          MapSet.member?(mapset, a) or MapSet.member?(mapset, x) -> [mapset_with_index | res]
          true -> res
        end
      end)
      |> case do
        {_mapset, :already_connected} ->
          circuits

        [{mapset1, i}, {mapset2, j}] ->
          other_circuits =
            circuits_with_index
            |> Enum.reject(fn {_, index} -> index in [i, j] end)
            |> Enum.map(fn {x, _} -> x end)

          updated_mapset =
            mapset1
            |> MapSet.union(mapset2)
            |> MapSet.put(a)
            |> MapSet.put(x)

          [updated_mapset | other_circuits]

        [{mapset, i}] ->
          other_circuits =
            circuits_with_index
            |> Enum.reject(fn {_, index} -> index == i end)
            |> Enum.map(fn {x, _} -> x end)

          updated_mapset =
            mapset
            |> MapSet.put(a)
            |> MapSet.put(x)

          [updated_mapset | other_circuits]

        [] ->
          [MapSet.new([a, x]) | circuits]
      end
    end)

    # |> IO.inspect(label: "updated circuits")

    # |> Enum.reduce(fn mapset ->
    #   mapset
    #   |> MapSet.member?(a)
    #   |> MapSet.put(x)
    # end)
  end

  defp make_connection(circuits) do
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.with_index()
    |> then(fn all_points ->
      all_points
      |> Enum.map(fn {point, index} ->
        all_points
        |> Enum.reject(fn {_, i} -> i == index end)
        |> Enum.map(fn {other_point, i} ->
          shortest_path(point, other_point)
          |> then(&{{point, index}, {other_point, i}, &1})
        end)

        # |> Enum.min_by(fn {_, _, distance} -> distance end)
      end)
      |> List.flatten()
      # |> Enum.count()
      |> Enum.sort_by(fn {_, _, distance} -> distance end)
    end)
    # |> Enum.take(10)
    |> Enum.chunk_every(2, 2)
    |> Enum.map(fn [x, _] -> x end)
    # |> IO.inspect(limit: :infinity)
    |> then(fn points_with_closest ->
      points_with_closest
      |> Enum.reduce_while({0, []}, fn {i, j, _}, {new_conns, circuits} ->
        {new_conns + 1, connect_junction_box(circuits, i, j)}
        |> then(fn
          {conn_count, _circuits} = x when conn_count < 1000 -> {:cont, x}
          {_conn_count, circuits} -> {:halt, circuits}
        end)
      end)
    end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.product()
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.with_index()
    |> then(fn all_points ->
      all_points
      |> Enum.map(fn {point, index} ->
        all_points
        |> Enum.reject(fn {_, i} -> i == index end)
        |> Enum.map(fn {other_point, i} ->
          shortest_path(point, other_point)
          |> then(&{{point, index}, {other_point, i}, &1})
        end)
      end)
      |> List.flatten()
      |> Enum.sort_by(fn {_, _, distance} -> distance end)
      # |> Enum.take(10)
      |> Enum.chunk_every(2, 2)
      |> Enum.map(fn [x, _] -> x end)
      # |> IO.inspect(limit: :infinity)
      |> then(fn points_with_closest ->
        init_circuits =
          all_points
          |> Enum.map(fn {_, index} -> MapSet.new([index]) end)

        Stream.unfold({init_circuits, points_with_closest, []}, fn
          {:halt, _} ->
            nil

          prev = {circuits, _, [last_processed | _]} when length(circuits) == 1 ->
            # IO.inspect({last_processed})
            {prev, {:halt, last_processed}}

          {circuits, [{i, j, _} | remaining_pairs], processed} = prev ->
            {prev, {connect_junction_box(circuits, i, j), remaining_pairs, [{i, j} | processed]}}
        end)
      end)
    end)
    |> Enum.take(-1)
    |> then(fn [{_, _, [{{[a, _, _], _}, {[x, _, _], _}} | _]}] -> [a, x] end)
    |> Enum.product()
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1          2.77      361.47 ms    ±10.46%      344.31 ms      436.38 ms
# part_2          2.54      394.29 ms    ±10.06%      395.90 ms      436.46 ms

# Comparison:
# part_1          2.77
# part_2          2.54 - 1.09x slower +32.81 ms

# Memory usage statistics:

# Name      Memory usage
# part_1       506.08 MB
# part_2       556.50 MB - 1.10x memory usage +50.42 MB
