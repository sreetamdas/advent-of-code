defmodule MonkeyMath do
  defp parse_operation(operation) do
    operation
    |> case do
      "+" -> &Kernel.+/2
      "-" -> &Kernel.-/2
      "*" -> &Kernel.*/2
      "/" -> &div/2
    end
  end

  defp get_reverse_operation(operation) do
    fn x, y, dir ->
      operation
      |> case do
        "-" ->
          case dir do
            :left -> y - x
            :right -> x + y
          end

        "+" ->
          x - y

        "/" ->
          x * y

        "*" ->
          div(x, y)

        _ ->
          x
      end
    end
  end

  defp get_operation_map([monkey_1, function, monkey_2]) do
    %{
      function: parse_operation(function),
      operation: function,
      left: String.to_atom(monkey_1),
      right: String.to_atom(monkey_2)
    }
  end

  defp update_map(map, current_monkey, solves_monkey) do
    map
    |> Map.update(
      String.to_atom(current_monkey),
      %{solves: [String.to_atom(solves_monkey)]},
      &Map.update(&1, :solves, [String.to_atom(solves_monkey)], fn solves ->
        [String.to_atom(solves_monkey) | solves]
      end)
    )
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, map ->
      line
      |> String.split(":", trim: true)
      |> then(fn [monkey, output] ->
        output
        |> String.trim()
        |> Integer.parse()
        |> case do
          {number, _} ->
            # update
            map
            |> Map.update(
              String.to_atom(monkey),
              %{number: number},
              &Map.merge(&1, %{number: number})
            )

          # solve
          :error ->
            output
            |> String.split(" ", trim: true)
            |> then(fn operation = [monkey_1, _function, monkey_2] ->
              map
              |> Map.update(
                String.to_atom(monkey),
                get_operation_map(operation),
                &Map.merge(&1, get_operation_map(operation))
              )
              |> update_map(monkey_1, monkey)
              |> update_map(monkey_2, monkey)
            end)
        end
      end)
    end)
  end

  defp from_monkey_to_monkey(map, end_monkey, end_monkey),
    do: [track(map, end_monkey)]

  defp from_monkey_to_monkey(map, start_monkey, end_monkey) do
    map
    |> Map.get(start_monkey)
    |> Map.get(:solves)
    |> then(fn [solves] ->
      solves
      |> then(&[track(map, start_monkey) | from_monkey_to_monkey(map, &1, end_monkey)])
    end)
  end

  defp track(map, current_monkey) do
    {dir, known_monkey} =
      map
      |> Map.get(current_monkey)
      |> Map.get(:solves, [nil])
      |> then(fn [solves_monkey] ->
        case solves_monkey do
          nil ->
            {:err, nil}

          _ ->
            map
            |> Map.get(solves_monkey)
            |> Map.take([:left, :right])
            |> case do
              %{left: ^current_monkey} = monkeys -> {:right, monkeys[:right]}
              %{right: ^current_monkey} = monkeys -> {:left, monkeys[:left]}
              _ -> "Naah"
            end
        end
      end)

    map
    |> Map.get(current_monkey)
    |> Map.get(:operation)
    |> then(
      &{
        current_monkey,
        {dir, map[known_monkey][:number]},
        get_reverse_operation(&1)
      }
    )
  end

  defp solve(map, monkey) do
    map
    |> Map.get(monkey)
    |> then(fn current_value ->
      case current_value do
        # number already exists, so either it was already given or has been computed
        %{number: number} ->
          {number, map}

        _ ->
          %{function: function, left: left, right: right} = current_value

          {left_number, left_updated_map} = solve(map, left)
          {right_number, right_updated_map} = solve(map, right)

          number = function.(left_number, right_number)

          updated_monkey =
            current_value
            |> Map.put(:number, number)

          updated_monkey_map =
            map
            |> Map.merge(left_updated_map, fn _key, old_monkey_props, new_monkey_props ->
              Map.merge(old_monkey_props, new_monkey_props)
            end)
            |> Map.merge(right_updated_map, fn _key, old_monkey_props, new_monkey_props ->
              Map.merge(old_monkey_props, new_monkey_props)
            end)
            |> Map.put(monkey, updated_monkey)

          {number, updated_monkey_map}
      end
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> solve(:root)
    |> elem(0)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> solve(:root)
    |> elem(1)
    |> then(fn map ->
      # Solve for children of :root
      {{left, left_number}, {right, right_number}} =
        map
        |> Map.get(:root)
        |> Map.take([:left, :right])
        |> then(fn %{left: left, right: right} ->
          left_number = map |> Map.get(left) |> Map.get(:number)
          right_number = map |> Map.get(right) |> Map.get(:number)

          {{left, left_number}, {right, right_number}}
        end)

      map
      |> from_monkey_to_monkey(:humn, :root)
      |> Enum.reverse()
      |> then(fn [_root | rest] ->
        # starting value from the :root's other child
        value_to_match =
          case elem(List.first(rest), 0) do
            ^left -> right_number
            ^right -> left_number
            _ -> raise "Naah"
          end

        rest
        |> Enum.with_index()
        |> Enum.reduce(value_to_match, fn {{_, _, operation}, index}, value ->
          {_, {next_dir, next}, _} = rest |> Enum.at(index + 1, {0, {:left, 0}, 0})

          operation.(value, next, next_dir)
        end)
      end)
    end)
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

MonkeyMath.part_1(input)
MonkeyMath.part_2(input)
