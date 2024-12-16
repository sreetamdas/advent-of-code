defmodule PulsePropagation do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn
      "broadcaster -> " <> starter_mods ->
        starter_mods
        |> String.split(", ")
        |> then(&{"broadcast", &1})

      "%" <> str ->
        # flip-flop
        [mod, dest_raw] = String.split(str, " -> ")

        dest = String.split(dest_raw, ", ", trim: true)

        {mod, {:flip, dest, :off}}

      "&" <> str ->
        # conjunction
        [mod, dest_raw] = String.split(str, " -> ")

        dest = String.split(dest_raw, ", ", trim: true)

        {mod, {:conj, dest, %{}}}
    end)
    |> then(fn init_entries ->
      conjs =
        init_entries
        |> Enum.flat_map(fn
          {node, {:conj, _, _}} -> [node]
          _ -> []
        end)

      conjunction_modules_input_map =
        init_entries
        |> Enum.reduce(%{}, fn
          {node, {_, dest_mods, _}}, conjs_map ->
            dest_mods
            |> Enum.filter(&Enum.member?(conjs, &1))
            |> case do
              [] ->
                conjs_map

              matches ->
                matches
                |> Enum.reduce(conjs_map, fn dest_mod, map ->
                  map
                  |> Map.update(dest_mod, %{node => :low}, fn input_mods ->
                    input_mods
                    |> Map.put(node, :low)
                  end)
                end)
            end

          _, conjs_map ->
            conjs_map
        end)

      {init_entries, conjunction_modules_input_map}
    end)
    |> then(fn {entries, conjs_map} ->
      entries
      |> Map.new()
      |> Map.merge(conjs_map, fn _, {:conj, dest, _}, inputs_map ->
        {:conj, dest, inputs_map}
      end)
    end)
  end

  defp check_if_all_inputs_high?(map) do
    map
    |> Map.values()
    |> Enum.all?(&(&1 == :high))
  end

  defp check_if_all_flip_flops_are_off?(map) do
    map
    |> Map.values()
    |> Enum.reduce_while(true, fn
      {:flip, _, :on}, _ ->
        {:halt, false}

      {:flip, _, :off}, _ ->
        {:cont, true}

      _, check ->
        {:cont, check}
    end)
  end

  defp process_module({node, signal, sender}, node_map) do
    node_map
    |> Map.get_and_update(node, fn node_details ->
      case node_details do
        {:flip, dest_mods, :off} when signal == :low ->
          dest_mods
          |> Enum.map(&{&1, :high, node})
          |> then(&{&1, {:flip, dest_mods, :on}})

        {:flip, dest_mods, :on} when signal == :low ->
          dest_mods
          |> Enum.map(&{&1, :low, node})
          |> then(&{&1, {:flip, dest_mods, :off}})

        {:conj, dest_mods, inputs} ->
          inputs
          |> Map.put(sender, signal)
          |> then(fn updated_inputs ->
            cond do
              check_if_all_inputs_high?(updated_inputs) ->
                dest_mods
                |> Enum.map(&{&1, :low, node})

              true ->
                dest_mods
                |> Enum.map(&{&1, :high, node})
            end
            |> then(&{&1, {:conj, dest_mods, updated_inputs}})
          end)

        {:output, _} = x ->
          {[], x}

        nil ->
          {[], {:output, []}}

        x ->
          {[], x}
      end
    end)
  end

  defp get_dependents(map, mod, one_level_deep \\ false) do
    map
    |> Map.to_list()
    |> Enum.flat_map(fn
      {src, {:conj, dest_mods, _}} ->
        dest_mods
        |> Enum.member?(mod)
        |> case do
          true when one_level_deep == false ->
            get_dependents(map, src, true)

          true ->
            [src]

          false ->
            []
        end

      {src, {:flip, dest_mods, _status}} ->
        dest_mods
        |> Enum.member?(mod)
        |> case do
          true ->
            [src]

          false ->
            []
        end

      _ ->
        []
    end)
  end

  defp is_high_signal_to_dependents({_node, signal, sender}, dependents) do
    cond do
      Enum.member?(dependents, sender) and signal == :high ->
        true

      true ->
        false
    end
  end

  defp process_signal(pulses, node_map, dependents \\ [], counts \\ {1, 0})

  defp process_signal([], node_map, _, counts), do: {{node_map, counts}, false}

  defp process_signal([pulse | rest_pulses], node_map, dependents, {low_count, high_count}) do
    pulse_counts =
      case pulse do
        {_, :high, _} -> {low_count, high_count + 1}
        {_, :low, _} -> {low_count + 1, high_count}
      end

    process_module(pulse, node_map)
    |> then(fn {next_modules, updated_map} ->
      rest_pulses
      |> add_lists(next_modules)
      |> process_signal(updated_map, dependents, pulse_counts)
      |> then(fn {result, dependent_high} ->
        {result, dependent_high || is_high_signal_to_dependents(pulse, dependents)}
      end)
    end)
  end

  defp add_lists(enumerator, list) do
    [enumerator | list]
    |> List.flatten()
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))

  def part_1(input) do
    {broadcast, parsed} =
      input
      |> parse_input()
      |> then(fn map ->
        broadcast = Map.get(map, "broadcast")

        {broadcast, map}
      end)

    broadcast
    |> Enum.map(&{&1, :low, "broadcast"})
    |> then(fn init_pulses ->
      1..1000
      |> Enum.reduce({parsed, {0, 0}, 0}, fn _, {map, {low_counts, high_counts}, all_off_count} ->
        init_pulses
        |> process_signal(map)
        |> then(fn {{updated_map, {updated_low_counts, updated_high_counts}}, _} ->
          cond do
            check_if_all_flip_flops_are_off?(updated_map) ->
              {updated_map, {low_counts + updated_low_counts, high_counts + updated_high_counts},
               all_off_count + 1}

            true ->
              {updated_map, {low_counts + updated_low_counts, high_counts + updated_high_counts},
               all_off_count}
          end
        end)
      end)
      |> then(fn {_, {lows, highs}, _} -> lows * highs end)
    end)
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    {broadcast, parsed} =
      input
      |> parse_input()
      |> then(fn map ->
        broadcast = Map.get(map, "broadcast")

        {broadcast, map}
      end)

    dependents = get_dependents(parsed, "rx")

    broadcast
    |> Enum.map(&{&1, :low, "broadcast"})
    |> then(fn init_pulses ->
      {parsed, [], 0, false}
      |> Stream.unfold(fn
        {:halt, cycles_list, _, _res} when length(cycles_list) == length(dependents) ->
          nil

        {_, cycles_list, _, _res} = input when length(cycles_list) == length(dependents) ->
          {input, {:halt, cycles_list}}

        {map, cycles_list, cycle_count, res} ->
          init_pulses
          |> process_signal(map, dependents)
          |> then(fn
            {{updated_map, _}, true} ->
              {{map, cycles_list, cycle_count, res},
               {updated_map, [cycle_count + 1 | cycles_list], cycle_count + 1, true}}

            {{updated_map, _}, false} ->
              {{map, cycles_list, cycle_count, res},
               {updated_map, cycles_list, cycle_count + 1, false}}
          end)
      end)
      |> Stream.filter(fn {_, _, _, dependent_high} -> dependent_high end)
      |> Stream.map(fn {_, cycles_list, _, _} -> cycles_list end)
      |> Enum.take(4)
      |> List.last()
      |> Enum.reduce(1, &lcm/2)
      |> IO.inspect(label: "part_2")
    end)
  end
end

input = Kino.Input.read(input_raw)

PulsePropagation.part_1(input)
PulsePropagation.part_2(input)
