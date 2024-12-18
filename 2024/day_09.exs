defmodule DiskFragmenter do
  def parse_input(input) do
    input
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 2, [0])
    |> then(fn chunks ->
      chunks
      |> Enum.with_index()
      |> Enum.scan({%{}, [], 0}, fn {[file, space], i}, {files, spaces, pos} ->
        updated_files =
          files
          |> Map.put(i, {pos, file})

        updated_spaces = if space == 0, do: spaces, else: [{pos + file, space} | spaces]

        {updated_files, updated_spaces, pos + file + space}
      end)
      |> Enum.take(-1)
      |> then(fn [{files_map, spaces_list, _}] ->
        {files_map, Enum.reverse(spaces_list)}
      end)
    end)
  end

  defp replicate(0, _), do: []
  defp replicate(n, x), do: for(_ <- 1..n, do: x)

  def part_1(input) do
    input
    |> parse_input()
    |> then(fn {files, spaces} ->
      total_spaces = Enum.sum_by(spaces, fn {_, len} -> len end)
      spaces_list = Enum.map(spaces, fn {_, len} -> len end)

      files_list =
        files
        |> Map.to_list()
        |> Enum.map(fn {id, {_pos, len}} ->
          replicate(len, id)
        end)

      spaces_list
      |> Enum.with_index()
      |> Enum.reduce(
        {files_list, List.flatten(files_list)},
        fn {space, i}, {updated_disk, remaining_files} ->
          remaining_files
          |> Enum.take(-space)
          |> then(&List.insert_at(updated_disk, 2 * i + 1, Enum.reverse(&1)))
          |> then(&{&1, Enum.drop(remaining_files, -space)})
        end
      )
      |> then(fn {x, _} -> x end)
      |> List.flatten()
      |> Enum.drop(-total_spaces)
      |> Enum.with_index()
      |> Enum.sum_by(fn {x, i} ->
        x * i
      end)
      |> IO.inspect(label: "part_1")
    end)
  end

  def part_2(input) do
    input
    |> parse_input()
    |> then(fn {files_init, spaces_init} ->
      file_id_init =
        files_init
        |> Map.keys()
        |> Enum.max()

      Stream.unfold({files_init, spaces_init, file_id_init}, fn
        {_, _, -1} ->
          nil

        {files, spaces, file_id} = cycle ->
          files
          |> Map.get(file_id)
          |> then(fn {file_pos, file_len} ->
            spaces
            |> Enum.with_index()
            |> Enum.reduce_while(nil, fn {{space_pos, space_len}, i}, _ ->
              cond do
                space_pos >= file_pos ->
                  {:halt, {cycle, {files, Enum.take(spaces, i), file_id - 1}}}

                file_len <= space_len ->
                  files
                  |> Map.put(file_id, {space_pos, file_len})
                  |> then(fn updated_files ->
                    updated_spaces =
                      if file_len == space_len do
                        List.delete_at(spaces, i)
                      else
                        List.replace_at(spaces, i, {space_pos + file_len, space_len - file_len})
                      end

                    {:halt, {cycle, {updated_files, updated_spaces, file_id - 1}}}
                  end)

                true ->
                  {:cont, {cycle, {files, spaces, file_id - 1}}}
              end
            end)
          end)
      end)
      |> Enum.to_list()
      |> Enum.take(-1)
      |> then(fn [{map, _, _}] ->
        map
        |> Map.to_list()
        |> Enum.sort_by(fn {_file_id, {file_pos, _file_len}} -> file_pos end)
      end)
      |> Enum.scan(0, fn {file_id, {file_pos, file_len}}, total ->
        file_pos..(file_pos + file_len - 1)
        |> Enum.sum_by(fn i ->
          file_id * i
        end)
        |> then(fn x ->
          x
        end)
      end)
      |> Enum.sum()
    end)
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input_09.txt")
DiskFragmenter.part_1(input)
DiskFragmenter.part_2(input)
