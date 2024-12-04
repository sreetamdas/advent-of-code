defmodule CeresSearch do
  @horizontal [{0, 0}, {0, 1}, {0, 2}, {0, 3}]
  @vertical [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
  @diagonal_down [{0, 0}, {1, 1}, {2, 2}, {3, 3}]
  @diagonal_up [{0, 0}, {-1, 1}, {-2, 2}, {-3, 3}]
  @part_1 [@horizontal, @vertical, @diagonal_down, @diagonal_up]

  @part_2 [[{-1, -1}, {0, 0}, {1, 1}, {-1, 1}, {1, -1}]]

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "", trim: true))
    |> to_grid()
  end

  def to_grid(input) do
    for {row, i} <- Enum.with_index(input),
        {x, j} <- Enum.with_index(row),
        into: %{} do
      {{i, j}, x}
    end
    |> then(&{&1, length(input), length(List.first(input))})
  end

  def matches(grid, {x, y}, direction, phrases),
    do:
      direction
      |> Enum.map(&Enum.map_join(&1, fn {i, j} -> grid[{x + i, y + j}] end))
      |> Enum.filter(&Enum.member?(phrases, &1))
      |> Enum.count()

  def part_1(input) do
    input
    |> parse_input()
    |> then(fn {grid, rows, cols} ->
      for r <- 0..(rows - 1), c <- 0..(cols - 1), reduce: 0 do
        count -> count + matches(grid, {r, c}, @part_1, ~w(XMAS SAMX))
      end
    end)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> then(fn {grid, rows, cols} ->
      for r <- 0..(rows - 1), c <- 0..(cols - 1), reduce: 0 do
        count ->
          count + matches(grid, {r, c}, @part_2, ~w(MASMS SAMMS SAMSM MASSM))
      end
    end)
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

CeresSearch.part_1(input)
CeresSearch.part_2(input)
