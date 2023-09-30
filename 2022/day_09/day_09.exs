defmodule RopeBridge do
  defp parse_input(input),
    do:
      input
      |> String.split(["\n", " "], trim: true)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [direction, steps] ->
        {direction, String.to_integer(steps)}
      end)

  defp repeat_step({dir, count}), do: List.duplicate(dir, count)

  defp move_head("R", {x, y}), do: {x + 1, y}
  defp move_head("L", {x, y}), do: {x - 1, y}
  defp move_head("U", {x, y}), do: {x, y + 1}
  defp move_head("D", {x, y}), do: {x, y - 1}

  defp get_straight_moves({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  defp get_diagonal_moves({x, y}),
    do: [{x + 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}, {x - 1, y + 1}]

  defp are_adjacent?({head_x, head_y}, {tail_x, tail_y}) do
    max(abs(head_x - tail_x), abs(head_y - tail_y))
    |> case do
      0 -> true
      1 -> true
      _ -> false
    end
  end

  defp do_move_tail(head = {head_x, head_y}, tail = {tail_x, tail_y}) do
    if head_x == tail_x or head_y == tail_y do
      head |> get_straight_moves() |> Enum.find(&are_adjacent?(tail, &1))
    else
      tail |> get_diagonal_moves() |> Enum.find(&are_adjacent?(head, &1))
    end
  end

  defp handle_tail(head, tail),
    do: if(are_adjacent?(head, tail), do: tail, else: do_move_tail(head, tail))

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.flat_map(&repeat_step/1)
    # move head
    |> Enum.scan({0, 0}, &move_head/2)
    # follow head's movement
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.uniq()
    |> Enum.count()
    |> IO.puts()
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.flat_map(&repeat_step/1)
    # move head
    |> Enum.scan({0, 0}, &move_head/2)
    # follow head's movement
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.scan({0, 0}, &handle_tail/2)
    |> Enum.uniq()
    |> Enum.count()
    |> IO.puts()
  end
end

input = File.read!("input.txt")

RopeBridge.part_1(input)
RopeBridge.part_2(input)
