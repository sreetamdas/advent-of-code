defmodule PerfectlySphericalHousesInAVacuum do
  def part_1(input) do
    input
    |> String.split("", trim: true)
    |> process_move({0, 0}, Map.new())
    |> Map.keys()
    |> length()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    all_moves =
      input
      |> String.split("", trim: true)

    santa_moves_map =
      all_moves
      |> Enum.take_every(2)
      |> process_move({0, 0}, Map.new())

    [_ | robot_moves] = all_moves

    robot_moves
    |> Enum.take_every(2)
    |> process_move({0, 0}, santa_moves_map)
    |> Map.keys()
    |> length()
    |> IO.inspect(label: "part_2")
  end

  defp process_move([], current_position, visits), do: move(visits, current_position)

  defp process_move([current_move | rest], current_position, visits) do
    process_move(
      rest,
      get_next_position(current_move, current_position),
      move(visits, current_position)
    )
  end

  defp get_next_position("^", {x, y}), do: {x, y + 1}
  defp get_next_position(">", {x, y}), do: {x + 1, y}
  defp get_next_position("v", {x, y}), do: {x, y - 1}
  defp get_next_position("<", {x, y}), do: {x - 1, y}

  defp move(visits, current_position), do: Map.update(visits, current_position, 1, &(&1 + 1))
end
