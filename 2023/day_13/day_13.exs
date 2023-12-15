defmodule PointOfIncidence do
  defp parse_input(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn block ->
      block
      |> String.split("\n")
    end)
  end

  defp transpose(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(&Enum.join/1)
  end

  defp find_possible_mirrors(rows) do
    rows
    |> Enum.chunk_every(2, 1)
    |> Enum.with_index()
    |> Enum.reduce_while([], fn
      {[row, row], index}, possible_mirror_indices -> {:cont, [index | possible_mirror_indices]}
      _, possible_mirror_indices -> {:cont, possible_mirror_indices}
    end)
  end

  defp check_confirmed_mirror(rows, {:vertical, indices}),
    do: check_confirmed_mirror(transpose(rows), {:horizontal, indices}, true)

  defp check_confirmed_mirror(rows, {:horizontal, indices}, is_vertical \\ false) do
    indices
    |> Enum.map(fn index ->
      rows
      |> Enum.split(index + 1)
      |> then(fn
        {a, b} when length(a) > length(b) ->
          a
          |> Enum.reverse()
          |> Enum.take(length(b))
          |> Kernel.==(b)

        {a, b} when length(a) < length(b) ->
          b
          |> Enum.take(length(a))
          |> Enum.reverse()
          |> Kernel.==(a)

        {a, b} ->
          a == Enum.reverse(b)
      end)
      |> case do
        true -> {index, is_vertical}
        false -> false
      end
      |> then(fn res ->
        res
      end)
    end)
    |> then(fn res ->
      cond do
        Enum.all?(res, &(&1 == false)) -> false
        true -> Enum.filter(res, &(&1 != false)) |> Enum.at(0)
      end
    end)
  end

  defp confirm_mirror({horizontal_mirror_indices, vertical_mirror_indices}, rows) do
    if res = check_confirmed_mirror(rows, {:horizontal, horizontal_mirror_indices}) do
      res
    else
      check_confirmed_mirror(rows, {:vertical, vertical_mirror_indices})
    end
    |> case do
      {index, true} ->
        index + 1

      {index, false} ->
        (index + 1) * 100
    end
  end

  defp find_mirrors(rows) do
    {find_possible_mirrors(rows), transpose(rows) |> find_possible_mirrors()}
    |> confirm_mirror(rows)
  end

  defp find_almost_mirror(rows, is_vertical \\ false) do
    0..(length(rows) - 1)
    |> Enum.reduce_while(0, fn index, _block_diff ->
      rows
      |> Enum.split(index + 1)
      |> then(fn {above, below} ->
        [Enum.reverse(above), below]
        |> Enum.zip()
        |> Enum.reduce(0, fn
          {first, first}, diff ->
            diff

          {first, second}, diff ->
            line_diff =
              [String.graphemes(first), String.graphemes(second)]
              |> Enum.zip()
              |> Enum.map(fn
                {a, a} -> 0
                {_, _} -> 1
              end)
              |> Enum.sum()

            line_diff + diff
        end)
        |> case do
          1 ->
            {:halt, index}

          _ ->
            {:cont, -1}
        end
      end)
    end)
    |> then(fn index ->
      cond do
        index == -1 -> false
        is_vertical -> index + 1
        true -> (index + 1) * 100
      end
    end)
  end

  defp find_almost_mirrors(rows) do
    if res = find_almost_mirror(rows) do
      res
    else
      rows |> transpose() |> find_almost_mirror(true)
    end
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&find_mirrors/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&find_almost_mirrors/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

PointOfIncidence.part_1(input)
PointOfIncidence.part_2(input)
