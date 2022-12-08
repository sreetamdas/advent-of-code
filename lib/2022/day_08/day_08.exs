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

  # trees on the left and right of our current base tree
  defp get_left_right_trees(trees, index),
    do: {Enum.slice(trees, 0, index) |> Enum.reverse(), Enum.slice(trees, (index + 1)..-1//1)}

  defp check_is_visible_from_edges(tree_row) do
    tree_row
    |> Enum.with_index(fn _, index ->
      cond do
        index == 0 || index == Enum.count(tree_row) - 1 ->
          true

        true ->
          base_tree = Enum.at(tree_row, index)

          {left, right} = get_left_right_trees(tree_row, index)

          base_tree > Enum.max(left) || base_tree > Enum.max(right)
      end
    end)
  end

  defp get_line_of_sight([next_tree | trees_line_of_sight], h) do
    cond do
      next_tree >= h || trees_line_of_sight == [] ->
        1

      true ->
        1 + get_line_of_sight(trees_line_of_sight, h)
    end
  end

  defp check_line_of_sight(tree_row) do
    tree_row
    |> Enum.with_index(fn _, index ->
      cond do
        index == 0 || index == Enum.count(tree_row) - 1 ->
          0

        true ->
          base_tree = Enum.at(tree_row, index)

          {left, right} = get_left_right_trees(tree_row, index)

          get_line_of_sight(left, base_tree) * get_line_of_sight(right, base_tree)
      end
    end)
  end

  defp compute_trees(input, visiblity_fn, score_fn) do
    visibility_horizontal =
      input
      |> Enum.map(&visiblity_fn.(&1))

    visibility_vertical =
      input
      |> Enum.zip_with(& &1)
      |> Enum.map(&visiblity_fn.(&1))
      |> Enum.zip_with(& &1)

    visibility_vertical
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
    |> compute_trees(&check_is_visible_from_edges/1, &(&1 || &2))
    |> Enum.count(&(&1 == true))
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> compute_trees(&check_line_of_sight/1, &(&1 * &2))
    |> Enum.max()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

TreetopTreeHouse.part_1(input)
TreetopTreeHouse.part_2(input)
