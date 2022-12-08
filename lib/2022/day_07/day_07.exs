defmodule NoSpaceLeftOnDevice do
  @moduledoc """
  Solution for Day 7 of Advent of Code 2022
  """

  @total_disk_space 70_000_000
  @update_size 30_000_000

  @part_1_file_size 100_000

  defp get_formatted_input(input),
    do:
      input
      |> String.trim_trailing()
      |> String.split("\n", trim: true)

  defp parse_line(line) do
    line
    |> String.split(" ")
    |> case do
      ["$" | command] ->
        command
        |> case do
          ["cd", dir_name] -> {:cd, dir_name}
          ["ls"] -> {:ls}
        end

      ["dir", dir_name] ->
        {:directory, dir_name}

      [file_size, file_name] ->
        {:file, file_name, String.to_integer(file_size)}
    end
  end

  defp get_pwd(sys), do: Map.get(sys, :pwd)

  defp add_file(sys, {_file_name, file_size}) do
    pwd = get_pwd(sys)

    updated_current_dir =
      sys
      |> Map.get(pwd)
      |> Map.update(:files, [], &(&1 ++ [file_size]))
      |> Map.update(:total_local, 0, &(&1 + file_size))
      |> Map.update(:total, 0, &(&1 + file_size))

    sys
    |> Map.put(pwd, updated_current_dir)
  end

  defp compile_directory(outputs) do
    outputs
    |> Enum.reduce(Map.new(), fn curr, sys ->
      curr
      |> case do
        {:cd, dir_name} ->
          sys
          |> get_pwd()
          |> then(fn pwd ->
            new_working_dir =
              dir_name
              |> case do
                ".." ->
                  pwd
                  |> String.split("/")
                  |> Enum.drop(-1)
                  |> Enum.join("/")
                  |> case do
                    "" -> "/"
                    x -> x
                  end

                "/" ->
                  dir_name

                _ ->
                  "#{if pwd == "/", do: "", else: pwd}/#{dir_name}"
              end

            sys
            |> Map.put(:pwd, new_working_dir)
            |> Map.put_new(new_working_dir, %{files: [], total_local: 0, total: 0, children: []})
          end)

        {:directory, dir_name} ->
          pwd = get_pwd(sys)

          # add as a child
          updated_current_dir =
            sys
            |> Map.get(pwd)
            |> Map.update(
              :children,
              [],
              &(&1 ++ ["#{if pwd == "/", do: "", else: pwd}/#{dir_name}"])
            )

          sys
          |> Map.put(pwd, updated_current_dir)

        {:file, file_name, file_size} ->
          sys
          |> add_file({file_name, file_size})

        _ ->
          sys
      end
    end)
  end

  defp sum_total_recursively(dir, system, name) do
    {children_total, sys_with_updated_children} =
      dir
      |> Map.get(:children)
      |> case do
        [] ->
          {0, system}

        children ->
          children
          |> Enum.reduce({0, system}, fn child, {total_current_dir_local, sys} ->
            {child_total, updated_system} =
              system
              |> Map.get(child)
              |> sum_total_recursively(sys, child)

            total =
              system
              |> Map.get(child)
              |> Map.get(:total_local)
              |> then(&(&1 + total_current_dir_local + child_total))

            {total, updated_system}
          end)
      end

    updated_sys =
      sys_with_updated_children
      |> Map.put(name, Map.put(dir, :total, children_total + dir[:total_local]))

    {children_total, updated_sys}
  end

  defp compute_totals(sys) do
    sys
    |> Map.get("/")
    |> sum_total_recursively(sys, "/")
    |> elem(1)
  end

  defp get_total_usage(input),
    do:
      input
      |> Map.values()
      |> Enum.reduce(
        0,
        &(Map.take(&1, [:total])
          |> Map.values()
          |> Enum.sum()
          |> Kernel.+(&2))
      )

  defp add_totals_info(input),
    do:
      input
      |> get_formatted_input()
      |> Enum.map(&parse_line(&1))
      |> compile_directory()
      |> compute_totals()
      |> Map.delete(:pwd)

  def part_1(input) do
    input
    |> add_totals_info()
    |> Map.filter(fn {_name, dir} -> dir[:total] <= @part_1_file_size end)
    |> get_total_usage()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    totals =
      input
      |> add_totals_info()

    total_usage =
      totals
      |> Map.get("/")
      |> Map.get(:total)

    current_free_space = @total_disk_space - total_usage

    totals
    |> Map.filter(fn {_name, dir} -> current_free_space + dir[:total] >= @update_size end)
    |> Map.values()
    |> Enum.flat_map(&(Map.take(&1, [:total]) |> Map.values()))
    |> Enum.min()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

NoSpaceLeftOnDevice.part_1(input)
NoSpaceLeftOnDevice.part_2(input)
