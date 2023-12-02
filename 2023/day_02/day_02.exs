defmodule CubeConundrum do
  @total_cubes %{
    :red => 12,
    :green => 13,
    :blue => 14
  }

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn game ->
      game
      |> String.split(":")
      |> Enum.drop(1)
      |> Enum.at(0)
      |> String.split(";", trim: true)
      |> Enum.map(fn cubes ->
        cubes
        |> String.split(",", trim: true)
        |> Enum.map(&parse_cubes/1)
      end)
    end)
  end

  def parse_cubes(cubes) do
    [count_str, color_str] =
      String.split(cubes, " ", trim: true)

    {String.to_integer(count_str), String.to_atom(color_str)}
  end

  def check_round({input, game_id}) do
    round_possible =
      input
      |> Enum.all?(fn cubes ->
        Enum.all?(cubes, fn {count, color} ->
          total_possible = Map.get(@total_cubes, color, 0)

          count <= total_possible
        end)
      end)

    if round_possible, do: [game_id + 1], else: []
  end

  def get_minimum_cubes(input) do
    input
    |> List.flatten()
    |> Enum.group_by(fn {_, color} -> color end, fn {count, _} -> count end)
    |> Map.to_list()
    |> Enum.map(fn {_color, count} -> Enum.max(count) end)
    |> Enum.product()
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.with_index()
    |> Enum.flat_map(&check_round/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&get_minimum_cubes/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

CubeConundrum.part_1(input)
CubeConundrum.part_2(input)
