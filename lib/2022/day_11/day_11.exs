defmodule MonkeyInTheMiddle do
  defp parse_operands(input, old) do
    input
    |> case do
      "old" -> old
      _ -> String.to_integer(input)
    end
  end

  defp parse_operation(instruction) do
    instruction
    |> String.split(" ")
    |> then(fn [operation, right] ->
      operation
      |> case do
        "+" -> fn x -> Kernel.+(x, parse_operands(right, x)) end
        "*" -> fn x -> Kernel.*(x, parse_operands(right, x)) end
      end
    end)
  end

  defp parse_input(input) do
    input
    |> String.split(["\n"], trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.chunk_every(6)
    |> Enum.reduce(Map.new(), fn monkey_details_raw, all_monkeys ->
      monkey_index =
        monkey_details_raw
        |> Enum.at(0)
        |> case do
          "Monkey " <> index ->
            index
            |> String.trim_trailing(":")
            |> String.to_integer()
        end

      monkey_init = %{:inspections => 0}

      monkey_details =
        monkey_details_raw
        |> Enum.reduce(monkey_init, fn info, monkey_info ->
          info
          |> case do
            "Starting items: " <> items ->
              monkey_info
              |> Map.put(
                :items,
                items
                |> String.split(", ")
                |> Enum.map(&String.to_integer(&1))
              )

            "Operation: new = old " <> instruction ->
              monkey_info
              |> Map.put(
                :operation,
                instruction
                |> parse_operation()
              )

            "Test: divisible by " <> divisor ->
              monkey_info
              |> Map.put(:test_divisor, String.to_integer(divisor))

            "If true: throw to monkey " <> to_monkey_index ->
              monkey_info
              |> Map.put(:test_true, String.to_integer(to_monkey_index))

            "If false: throw to monkey " <> to_monkey_index ->
              monkey_info
              |> Map.put(:test_false, String.to_integer(to_monkey_index))

            _ ->
              monkey_info
          end
        end)

      all_monkeys |> Map.put(monkey_index, monkey_details)
    end)
  end

  defp carry_out_operation(monkey_details, relief_func, common_divisor) do
    %{
      :items => items,
      :operation => operation,
      :test_divisor => test_divisor,
      :test_true => test_true,
      :test_false => test_false
    } =
      monkey_details
      |> Map.take([:items, :operation, :test_divisor, :test_true, :test_false])

    items
    |> Enum.map(fn item ->
      item
      |> operation.()
      # part_2
      |> relief_func.()
      |> floor()
      |> then(fn updated_worry_level ->
        updated_worry_level
        |> rem(test_divisor)
        |> case do
          0 ->
            test_true

          _ ->
            test_false
        end
        |> then(&{&1, rem(updated_worry_level, common_divisor)})
      end)
    end)
  end

  defp get_common_divisor(monkey_map) do
    monkey_map
    |> Map.values()
    |> Enum.map(&Map.get(&1, :test_divisor))
    |> Enum.product()
  end

  defp run_round(monkey_map_initial, relief_func) do
    common_divisor = get_common_divisor(monkey_map_initial)

    monkey_map_initial
    |> Map.keys()
    # run a round, loop through all monkeys
    |> Enum.reduce(monkey_map_initial, fn monkey_number, all_monkeys_map ->
      {send_items, all_monkeys_with_current_updated} =
        all_monkeys_map
        # each monkey's turn
        |> Map.get_and_update(monkey_number, fn monkey_details ->
          operation_results =
            monkey_details
            |> carry_out_operation(relief_func, common_divisor)

          # Update current monkey
          monkey_details
          # update inspections
          |> Map.update!(:inspections, &(&1 + length(operation_results)))
          # Pop/throw out all items
          |> Map.replace(:items, [])
          |> then(&{operation_results, &1})
        end)

      # Update other monkeys before running their turns
      send_items
      |> Enum.reduce(all_monkeys_with_current_updated, fn operation, other_updated_monkeys ->
        operation
        |> case do
          {monkey_index, item} ->
            other_updated_monkeys
            |> Map.update!(monkey_index, fn monkey_current ->
              monkey_current |> Map.update!(:items, &(&1 ++ [item]))
            end)
        end
      end)
    end)
  end

  defp run_all_rounds(input, count, relief_func) do
    1..count
    |> Enum.reduce(input, fn _, monkey_map_final ->
      monkey_map_final
      |> run_round(relief_func)
    end)
  end

  defp get_monkey_business(monkey_map) do
    monkey_map
    |> Map.values()
    |> Enum.map(&Map.get(&1, :inspections))
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> then(fn [first, second] -> first * second end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> run_all_rounds(20, &Kernel.div(&1, 3))
    |> get_monkey_business()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> run_all_rounds(100_00, &Function.identity/1)
    |> get_monkey_business()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

MonkeyInTheMiddle.part_1(input)
MonkeyInTheMiddle.part_2(input)
