defmodule LensLibrary do
  defp parse_input(input) do
    input
    |> String.split(",")
    |> Enum.map(fn
      group ->
        group
        |> String.reverse()
        |> case do
          "-" <> label_reverse ->
            {:dash, label_reverse |> String.reverse()}

          other ->
            [label, box_num] =
              other
              |> String.reverse()
              |> String.split("=")

            {:equal, label, String.to_integer(box_num)}
        end
    end)
  end

  defp get_hash(input) do
    input
    |> String.graphemes()
    |> Enum.reduce(0, fn each, sum ->
      each
      |> String.to_charlist()
      |> hd()
      |> Kernel.+(sum)
      |> then(&(&1 * 17))
      |> then(&rem(&1, 256))
    end)
  end

  defp build_hashmap(inputs, map) do
    inputs
    |> Enum.reduce(map, fn
      {:dash, block}, updated_map ->
        box_num = get_hash(block)

        cond do
          Map.has_key?(updated_map, box_num) ->
            updated_map
            |> Map.update!(box_num, fn
              values ->
                values
                |> Enum.find_index(fn
                  {^block, _len} -> true
                  _ -> false
                end)
                |> then(fn
                  nil ->
                    values

                  index when is_integer(index) ->
                    {_, res} = List.pop_at(values, index)

                    res
                end)
            end)

          true ->
            updated_map
        end

      {:equal, block, len}, updated_map ->
        box_num = get_hash(block)

        updated_map
        |> Map.update(box_num, [{block, len}], fn
          values ->
            values
            |> Enum.find_index(fn
              {^block, _len} -> true
              _ -> false
            end)
            |> then(fn
              nil ->
                values
                |> Enum.reverse()
                |> then(&[{block, len} | &1])
                |> Enum.reverse()

              index when is_integer(index) ->
                List.replace_at(values, index, {block, len})
            end)
        end)
    end)
  end

  defp get_res(input_map) do
    input_map
    |> Map.reject(fn {_, val} -> Enum.empty?(val) end)
    |> Map.keys()
    |> Enum.map(fn index ->
      input_map
      |> Map.get(index)
      |> Enum.with_index()
      |> Enum.reduce(0, fn {{_, len}, slot}, sum ->
        sum + (index + 1) * (slot + 1) * len
      end)
    end)
  end

  def part_1(input) do
    input
    |> String.split(",")
    |> Enum.reduce(0, &(&2 + get_hash(&1)))
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> build_hashmap(%{})
    |> get_res()
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

LensLibrary.part_1(input)
LensLibrary.part_2(input)
