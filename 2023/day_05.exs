defmodule Scratchcards do
  defp parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.map(fn category ->
      case length(category) do
        1 ->
          category
          |> Enum.at(0)
          |> String.split([":", " "], trim: true)
          |> then(fn [_ | indices_str] ->
            {:seeds, Enum.map(indices_str, &String.to_integer/1)}
          end)

        _ ->
          ranges =
            category
            |> Enum.drop(1)
            |> Enum.map(fn nums ->
              nums
              |> String.split(" ")
              |> Enum.map(&String.to_integer/1)
            end)

          category
          |> Enum.at(0)
          |> String.split(" ")
          |> Enum.at(0)
          |> String.split("-")
          |> then(fn [dest, _, src] -> {String.to_atom(dest), String.to_atom(src), ranges} end)
      end
    end)
  end

  defp mark_ranges(input, init_seeds) do
    input
    |> Enum.reduce(init_seeds, fn {_src, _dest, ranges}, seeds ->
      seeds
      |> Enum.map(fn seed_num ->
        ranges
        |> Enum.reduce_while(seed_num, fn [dest, src, len], x ->
          if x >= src and x < src + len do
            {:halt, x + (dest - src)}
          else
            {:cont, x}
          end
        end)
      end)
    end)
  end

  defp split_seed_range(
         {dest, src, len},
         {seed_start, seed_end} = seed_range,
         {done, remaining}
       ) do
    cond do
      # range within seeds
      seed_start < src and seed_end > src + len ->
        {[{dest, len + dest} | done],
         [{seed_start, src - 1}, {src + len + 1, seed_end}] ++ remaining}

      # seeds within range
      seed_start >= src and seed_end <= src + len ->
        {[{seed_start - src + dest, seed_end - src + dest} | done], remaining}

      # range left of seeds
      seed_start in src..(src + len) and seed_end > src + len ->
        {[{seed_start - src + dest, len + dest} | done], [{src + len + 1, seed_end} | remaining]}

      # range right of seeds
      seed_end in src..(src + len) and seed_start < src ->
        {[{dest, seed_end - src + dest} | done], [{seed_start, src - 1} | remaining]}

      # no overlap
      true ->
        {done, [seed_range | remaining]}
    end
  end

  defp process_seeds({processed, remaining}, []), do: processed ++ remaining
  defp process_seeds({processed, []}, _tranformation_ranges), do: processed

  defp process_seeds({processed, remaining}, [[dest, src, len] | tranformation_ranges]) do
    remaining
    |> Enum.reduce({processed, []}, fn seed_range, seed_ranges ->
      split_seed_range({dest, src, len}, seed_range, seed_ranges)
    end)
    |> process_seeds(tranformation_ranges)
  end

  defp mark_2(transformations, init_seed_ranges) do
    transformations
    |> Enum.reduce(init_seed_ranges, fn {_, _, ranges}, seed_ranges ->
      process_seeds({[], seed_ranges}, ranges)
    end)
  end

  def part_1(input) do
    [{_, seeds} | parsed_input] =
      input
      |> parse_input()

    parsed_input
    |> mark_ranges(seeds)
    |> Enum.min()
    |> IO.inspect(label: "part_1", charlists: :as_lists)
  end

  def part_2(input) do
    [{_, seeds} | parsed_transformations] =
      input
      |> parse_input()

    seed_ranges =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, len] -> {start, start + len - 1} end)

    parsed_transformations
    |> mark_2(seed_ranges)
    |> Enum.min_by(&elem(&1, 0))
    |> elem(0)
    |> IO.inspect(label: "part_2", charlists: :as_lists)
  end
end

input = File.read!("input.txt")

Scratchcards.part_1(input)
Scratchcards.part_2(input)
