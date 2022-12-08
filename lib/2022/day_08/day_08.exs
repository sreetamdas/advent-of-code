defmodule TreetopTreeHouse do
  @moduledoc """
  Solution for Day 8 of Advent of Code 2022
  """

  defp parse_input(input),
    do:
      input
      |> String.trim_trailing()
      |> String.split("\n", trim: true)
      |> Enum.map(fn num ->
        num
        |> String.split("", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

  defp check_is_visible_from_edges(tree_row, index) do
    cond do
      index == 0 ->
        true

      index == Enum.count(tree_row) - 1 ->
        true

      true ->
        Enum.at(tree_row, index) >
          Enum.max(Enum.slice(tree_row, 0, index)) ||
          Enum.at(tree_row, index) >
            Enum.max(Enum.slice(tree_row, (index + 1)..-1//1))
    end
  end

  defp get_line_of_sight([next_tree | trees_line_of_sight], h) do
    cond do
      next_tree >= h ->
        1

      trees_line_of_sight == [] ->
        1

      true ->
        1 + get_line_of_sight(trees_line_of_sight, h)
    end
  end

  defp check_line_of_sight(tree_row, index) do
    cond do
      index == 0 ->
        0

      index == Enum.count(tree_row) - 1 ->
        0

      true ->
        base_tree = Enum.at(tree_row, index)

        {left, right} =
          {Enum.slice(tree_row, 0, index) |> Enum.reverse(),
           Enum.slice(tree_row, (index + 1)..-1//1)}

        get_line_of_sight(left, base_tree) * get_line_of_sight(right, base_tree)
    end
  end

  defp check_row_visibility(tree_row, func) do
    tree_row
    |> Enum.with_index(fn tree, i ->
      {tree, func.(tree_row, i)}
    end)
  end

  defp compute_trees(input, visiblity_func, score_fn) do
    rotated_90 =
      input
      |> Enum.zip_with(& &1)

    visibility_horizontal =
      input
      |> Enum.map(fn row ->
        row
        |> check_row_visibility(visiblity_func)
      end)

    visibility_vertical =
      rotated_90
      |> Enum.map(fn row ->
        row
        |> check_row_visibility(visiblity_func)
      end)

    visibility_vertical
    |> Enum.zip_with(& &1)
    |> Enum.with_index(fn vertical_row, index ->
      visibility_horizontal
      |> Enum.at(index)
      |> Enum.zip_with(vertical_row, &score_fn.(&1, &2))
    end)
    |> List.flatten()
  end

  def part_1(input) do
    input
    |> parse_input()
    |> compute_trees(&check_is_visible_from_edges/2, fn {_, vis_h}, {_, vis_v} ->
      vis_h ||
        vis_v
    end)
    |> Enum.count(&(&1 == true))
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> compute_trees(&check_line_of_sight/2, fn {_, vis_h}, {_, vis_v} ->
      vis_h *
        vis_v
    end)
    |> Enum.max()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

TreetopTreeHouse.part_1(input)

TreetopTreeHouse.part_2(input)
