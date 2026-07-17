defmodule Factory do
  import Bitwise

  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      tokens = String.split(line, " ")
      [lights | rest] = tokens
      {joltage_str, button_strs} = List.pop_at(rest, -1)

      goal =
        lights
        |> String.slice(1..-2//1)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(0, fn
          {"#", i}, acc -> acc ||| (1 <<< i)
          _, acc -> acc
        end)

      button_masks =
        Enum.map(button_strs, fn btn ->
          btn
          |> String.slice(1..-2//1)
          |> String.split(",")
          |> Enum.reduce(0, fn s, acc -> acc ||| (1 <<< String.to_integer(s)) end)
        end)

      button_sets =
        Enum.map(button_strs, fn btn ->
          btn |> String.slice(1..-2//1) |> String.split(",") |> Enum.map(&String.to_integer/1)
        end)

      joltage =
        joltage_str |> String.slice(1..-2//1) |> String.split(",") |> Enum.map(&String.to_integer/1)

      {goal, button_masks, joltage, button_sets}
    end)
  end

  defp min_presses(goal, buttons) do
    n = length(buttons)
    Enum.reduce(0..((1 <<< n) - 1), n, fn mask, acc ->
      {result, count} =
        buttons |> Enum.with_index() |> Enum.reduce({0, 0}, fn {btn, i}, {res, cnt} ->
          if (mask >>> i &&& 1) == 1, do: {Bitwise.bxor(res, btn), cnt + 1}, else: {res, cnt}
        end)
      if result == goal and count < acc, do: count, else: acc
    end)
  end

  def part_1(input) do
    input |> parse_input() |> Enum.map(fn {g, b, _, _} -> min_presses(g, b) end) |> Enum.sum()
  end

  # ------------------------------------------------------------
  # Part 2: Valid greedy upper bound + DFS with strong pruning
  # ------------------------------------------------------------

  defp solve_machine(targets, button_sets) do
    n = length(button_sets)
    # Order: larger sets first -> smaller max_x -> tighter search
    order = 0..(n - 1) |> Enum.sort_by(fn j -> -length(Enum.at(button_sets, j)) end)
    sorted = Enum.map(order, &Enum.at(button_sets, &1))

    # Valid greedy upper bound
    upper = valid_greedy(targets, sorted)

    dfs(0, sorted, targets, 0, upper)
  end

  defp valid_greedy(targets, buttons) do
    do_greedy(targets, buttons, 0)
  end

  defp do_greedy(rem, buttons, cost) do
    if Enum.all?(rem, &(&1 == 0)) do
      cost
    else
      # Find a counter with the fewest remaining buttons, and press its button
      {i, btns} =
        rem
        |> Enum.with_index()
        |> Enum.filter(fn {r, _} -> r > 0 end)
        |> Enum.map(fn {_, i} ->
          affecting =
            buttons
            |> Enum.with_index()
            |> Enum.filter(fn {set, _j} -> i in set and Enum.all?(Enum.map(set, fn k -> Enum.at(rem, k) end), &(&1 >= 0)) end)
            |> Enum.map(fn {_, j} -> j end)
          {i, affecting}
        end)
        |> Enum.min_by(fn {_, btns} -> length(btns) end, fn -> {nil, []} end)

      if i == nil or btns == [] do
        # Fallback: very loose bound
        Enum.sum(rem)
      else
        # Choose the button with smallest set among options
        j = Enum.min_by(btns, fn j -> length(Enum.at(buttons, j)) end)
        set = Enum.at(buttons, j)
        x = Enum.at(rem, i)
        new_rem = Enum.map(Enum.with_index(rem), fn {r, k} -> if k in set, do: r - x, else: r end)
        if Enum.any?(new_rem, &(&1 < 0)) do
          Enum.sum(rem)
        else
          do_greedy(new_rem, buttons, cost + x)
        end
      end
    end
  end

  defp lower_bound(remaining, cost, idx, buttons) do
    rem_nonzero = Enum.filter(remaining, &(&1 > 0))
    if rem_nonzero == [] do
      cost
    else
      max_r = Enum.max(rem_nonzero)
      sum_r = Enum.sum(rem_nonzero)
      n = length(buttons)
      max_set =
        if idx >= n do
          1
        else
          idx..(n - 1)//1
          |> Enum.map(fn j -> length(Enum.at(buttons, j)) end)
          |> Enum.max(fn -> 1 end)
        end
      lb2 = div(sum_r + max_set - 1, max_set)
      cost + max(max_r, lb2)
    end
  end

  defp infeasible?(remaining, idx, buttons) do
    n = length(buttons)
    remaining
    |> Enum.with_index()
    |> Enum.any?(fn {r, i} ->
      r > 0 and (idx >= n or not Enum.any?(idx..(n - 1)//1, fn j -> i in Enum.at(buttons, j) end))
    end)
  end

  defp dfs(idx, buttons, remaining, cost, best) when idx == length(buttons) do
    if Enum.all?(remaining, &(&1 == 0)), do: min(cost, best), else: best
  end

  defp dfs(idx, buttons, remaining, cost, best) do
    if cost >= best do
      best
    else
      lb = lower_bound(remaining, cost, idx, buttons)
      if lb >= best do
        best
      else
        if infeasible?(remaining, idx, buttons) do
          best
        else
          set = Enum.at(buttons, idx)
          max_x = Enum.reduce(set, best - cost - 1, fn i, acc -> min(acc, Enum.at(remaining, i)) end)
          # Descending: try efficient large presses first
          dfs_branch(max_x, idx, buttons, set, remaining, cost, best)
        end
      end
    end
  end

  defp dfs_branch(x, _idx, _buttons, _set, _remaining, _cost, best) when x < 0, do: best
  defp dfs_branch(x, idx, buttons, set, remaining, cost, best) do
    new_cost = cost + x
    if new_cost >= best do
      best
    else
      new_rem = Enum.map(Enum.with_index(remaining), fn {r, i} -> if i in set, do: r - x, else: r end)
      lb = lower_bound(new_rem, new_cost, idx + 1, buttons)
      if lb >= best do
        best
      else
        result = dfs(idx + 1, buttons, new_rem, new_cost, best)
        dfs_branch(x - 1, idx, buttons, set, remaining, cost, result)
      end
    end
  end

  def part_2(input) do
    input |> parse_input() |> Enum.map(fn {_, _, j, bs} -> solve_machine(j, bs) end) |> Enum.sum()
  end
end
