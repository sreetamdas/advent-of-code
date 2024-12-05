defmodule PrintQueue do
  def parse_input(input) do
    input
    |> String.split("\n\n")
    |> then(fn [rules_raw, pages_raw] ->
      rules =
        rules_raw
        |> String.split("\n")
        |> Enum.map(&String.split(&1, "|"))

      pages =
        pages_raw
        |> String.split("\n")
        |> Enum.map(&String.split(&1, ","))

      {rules, pages}
    end)
  end

  def check(nums, rules) do
    nums
    |> Enum.reduce_while({false, []}, fn num, {_, before} ->
      before
      |> Enum.all?(&Enum.member?(rules, [&1, num]))
      |> case do
        true -> {:cont, {true, [num | before]}}
        _ -> {:halt, {false, nums}}
      end
    end)
  end

  def get_middle(nums) do
    nums
    |> length()
    |> div(2)
    |> then(&Enum.at(nums, &1))
    |> String.to_integer()
  end

  def part_1(input) do
    {rules, pages} = parse_input(input)

    pages
    |> Enum.map(&check(&1, rules))
    |> Enum.filter(&elem(&1, 0))
    |> Enum.reduce(0, &(get_middle(elem(&1, 1)) + &2))
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    {rules, pages} = parse_input(input)

    pages
    |> Enum.map(&check(&1, rules))
    |> Enum.reject(&elem(&1, 0))
    |> Enum.map(fn {_, list} ->
      list
      |> Enum.sort(&Enum.any?(rules, fn rule -> rule == [&1, &2] end))
    end)
    |> Enum.reduce(0, &(get_middle(&1) + &2))
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

PrintQueue.part_1(input)
PrintQueue.part_2(input)
