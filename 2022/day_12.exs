defmodule HillClimbingAlgorithm do
  defp parse_input(input) do
    input
    |> String.split(["\n"], trim: true)
    |> Enum.map(fn all ->
      String.split(all, "", trim: true)
      |> Enum.map(fn row ->
        String.to_charlist(row)
        |> hd
        |> then(&(&1 - 96))
        |> then(fn val ->
          case val do
            -13 -> 0
            -27 -> 27
            _ -> val
          end
        end)
      end)
    end)
  end

  defp get_node(graph, {x, y}), do: graph |> Enum.at(x) |> Enum.at(y)

  defp get_neighbour(graph, {x, y}, value, directions) do
    left = get_node(graph, {x, y - 1})
    right = get_node(graph, {x, y + 1})
    up = get_node(graph, {x - 1, y})
    down = get_node(graph, {x + 1, y})

    %{
      :left => {:left, left, {x, y - 1}},
      :right => {:right, right, {x, y + 1}},
      :up => {:up, up, {x - 1, y}},
      :down => {:down, down, {x + 1, y}}
    }
    |> Map.take(directions)
    |> Map.filter(&(elem(&1, 1) |> elem(1) |> Kernel.-(value) |> Kernel.<=(1)))
    |> Map.values()
  end

  defp get_neighbours(graph, node_position) do
    current_node_value = get_node(graph, node_position)

    height = Enum.count(graph) - 1
    width = Enum.count(graph |> Enum.at(0)) - 1

    case node_position do
      # clockwise from top-left
      {0, 0} ->
        get_neighbour(graph, node_position, current_node_value, [:down, :right])

      {0, ^width} ->
        get_neighbour(graph, node_position, current_node_value, [:down, :left])

      {^height, 0} ->
        get_neighbour(graph, node_position, current_node_value, [:up, :right])

      {^height, ^width} ->
        get_neighbour(graph, node_position, current_node_value, [:up, :left])

      {0, _} ->
        get_neighbour(graph, node_position, current_node_value, [:down, :left, :right])

      {^height, _} ->
        get_neighbour(graph, node_position, current_node_value, [:up, :left, :right])

      {_, 0} ->
        get_neighbour(graph, node_position, current_node_value, [:up, :down, :right])

      {_, ^width} ->
        get_neighbour(graph, node_position, current_node_value, [:up, :down, :left])

      _ ->
        get_neighbour(graph, node_position, current_node_value, [:up, :down, :left, :right])
    end
  end

  @initial_start {2, 3}
  defp construct_graph(input) do
    input
    |> get_neighbours(@initial_start)
    |> dbg()
  end

  def part_1(input) do
    input
    |> parse_input()
    |> IO.inspect(label: "part_1")
    |> construct_graph()
  end

  def part_2(input) do
    input
    |> parse_input()
    |> IO.inspect(label: "part_2")
  end
end

input =
  input_12
  |> Kino.Input.read()

HillClimbingAlgorithm.part_1(input)
# HillClimbingAlgorithm.part_2(input)
