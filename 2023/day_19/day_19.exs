defmodule Aplenty do
  defp parse_input(input) do
    [workflows, parts] = String.split(input, "\n\n")

    parsed_parts =
      parts
      |> String.split("\n")
      |> Enum.map(fn row ->
        row
        |> String.trim_leading("{")
        |> String.trim_trailing("}")
        |> String.split(["=", ","])
        |> Enum.chunk_every(2)
        |> Enum.map(fn [var, val] -> {var, String.to_integer(val)} end)
      end)

    parsed_workflows =
      workflows
      |> String.split("\n")
      |> Enum.map(fn row ->
        row
        |> String.split("{")
        |> then(fn [name, rules_raw] ->
          rules_raw
          |> String.trim_trailing("}")
          |> String.split(",")
          |> parse_rules()
          |> then(&{name, &1})
        end)
      end)
      |> Map.new()

    {parsed_parts, parsed_workflows}
  end

  defp parse_rules([dest]) do
    [{:dest, dest}]
  end

  defp parse_rules([rule_raw | rest_rules_raw]) do
    rule_raw
    |> String.split(":")
    |> then(fn [rule, dest] ->
      cond do
        String.contains?(rule, ">") ->
          rule
          |> String.split(["<", ">"])
          |> then(fn [var, val] ->
            {var, String.to_integer(val), &Kernel.>/2, dest}
          end)

        true ->
          rule
          |> String.split(["<", ">"])
          |> then(fn [var, val] ->
            {var, String.to_integer(val), &Kernel.</2, dest}
          end)
      end
    end)
    |> then(fn x ->
      [x | parse_rules(rest_rules_raw)]
    end)
  end

  defp solve(part_ratings, workflows, rule_name \\ "in")
  defp solve(part_ratings, _workflows, "A"), do: {:accept, part_ratings}
  defp solve(part_ratings, _workflows, "R"), do: {:reject, part_ratings}

  defp solve(part_ratings, workflows, rule_name) do
    workflows
    |> Map.get(rule_name)
    |> then(fn rules ->
      rules
      |> Enum.reduce_while(nil, fn
        {var, val, op, dest}, _ ->
          {_, var_rating} =
            part_ratings
            |> Enum.find(nil, fn
              {^var, _} -> true
              _ -> false
            end)

          cond do
            op.(var_rating, val) ->
              {:halt, solve(part_ratings, workflows, dest)}

            true ->
              {:cont, part_ratings}
          end

        {:dest, rule_last_dest}, part_ratings ->
          {:halt, solve(part_ratings, workflows, rule_last_dest)}
      end)
    end)
  end

  def part_1(input) do
    {parsed_parts, parsed_workflows} =
      input
      |> parse_input()

    parsed_parts
    |> Enum.map(&solve(&1, parsed_workflows))
    |> Enum.filter(&(elem(&1, 0) == :accept))
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(fn xmas ->
      xmas
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end
end

input = File.read!("input.txt")

Aplenty.part_1(input)
