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
  # Part 2: exact solve via Gaussian elimination over the reals,
  # then bounded enumeration over the free variables.
  #
  # Each button press adds 1 to every counter it lists, so the
  # counts x_j >= 0 must satisfy A·x = targets, minimising Σx_j.
  # Row-reducing pins most buttons to a single expression; only a
  # handful of columns stay free (0-3 for this input), and each is
  # bounded by the smallest target it touches, so we can enumerate
  # them and verify each candidate exactly with integer arithmetic.
  # ------------------------------------------------------------

  defp solve_machine(targets, button_sets) do
    m = length(targets)
    n = length(button_sets)
    targets_t = List.to_tuple(targets)

    matrix =
      for i <- 0..(m - 1) do
        row = Enum.map(button_sets, fn set -> if i in set, do: 1.0, else: 0.0 end)
        row ++ [elem(targets_t, i) * 1.0]
      end

    {reduced, pivots} = rref(matrix, n)
    pivot_cols = MapSet.new(pivots, fn {_r, c} -> c end)
    free_cols = Enum.reject(0..(n - 1), &MapSet.member?(pivot_cols, &1))

    uppers =
      Enum.map(free_cols, fn f ->
        button_sets |> Enum.at(f) |> Enum.map(&elem(targets_t, &1)) |> Enum.min()
      end)

    pivot_exprs =
      Enum.map(pivots, fn {pr, pc} ->
        row = Enum.at(reduced, pr)
        {pc, Enum.at(row, n), Enum.map(free_cols, fn f -> Enum.at(row, f) end)}
      end)

    ctx = %{pivot_exprs: pivot_exprs, free_cols: free_cols, sets: button_sets, targets: targets_t, m: m, n: n}

    uppers
    |> Enum.reduce([[]], fn ub, combos -> for combo <- combos, v <- 0..ub, do: combo ++ [v] end)
    |> Enum.map(&candidate_cost(&1, ctx))
    |> Enum.min()
  end

  defp swap(list, i, j) do
    vi = Enum.at(list, i)
    vj = Enum.at(list, j)
    list |> List.replace_at(i, vj) |> List.replace_at(j, vi)
  end

  defp rref(rows, n) do
    {rs, _pr, pivots} =
      Enum.reduce(0..(n - 1), {rows, 0, []}, fn col, {rs, pr, pivots} ->
        pivot_idx =
          rs
          |> Enum.drop(pr)
          |> Enum.find_index(fn row -> abs(Enum.at(row, col)) > 1.0e-9 end)

        if pivot_idx == nil do
          {rs, pr, pivots}
        else
          p = pr + pivot_idx
          rs = swap(rs, pr, p)
          pivrow = Enum.at(rs, pr)
          pv = Enum.at(pivrow, col)
          pivrow = Enum.map(pivrow, &(&1 / pv))
          rs = List.replace_at(rs, pr, pivrow)

          rs =
            rs
            |> Enum.with_index()
            |> Enum.map(fn {row, ri} ->
              if ri == pr do
                row
              else
                f = Enum.at(row, col)
                Enum.zip_with(row, pivrow, fn a, b -> a - f * b end)
              end
            end)

          {rs, pr + 1, [{pr, col} | pivots]}
        end
      end)

    {rs, Enum.reverse(pivots)}
  end

  defp candidate_cost(free_vals, ctx) do
    pivots =
      Enum.map(ctx.pivot_exprs, fn {pc, base, coeffs} ->
        {pc, round(base - dot(coeffs, free_vals))}
      end)

    if Enum.all?(pivots, fn {_pc, r} -> r >= 0 end) do
      x =
        ctx.free_cols
        |> Enum.zip(free_vals)
        |> Enum.concat(pivots)
        |> Enum.reduce(List.duplicate(0, ctx.n), fn {col, v}, acc -> List.replace_at(acc, col, v) end)

      if verify(x, ctx.sets, ctx.targets, ctx.m), do: Enum.sum(x), else: :infinity
    else
      :infinity
    end
  end

  defp dot(coeffs, vals), do: coeffs |> Enum.zip_with(vals, fn c, v -> c * v end) |> Enum.sum()

  defp verify(x, sets, targets, m) do
    xt = List.to_tuple(x)

    totals =
      sets
      |> Enum.with_index()
      |> Enum.reduce(:erlang.make_tuple(m, 0), fn {set, j}, acc ->
        xj = elem(xt, j)
        Enum.reduce(set, acc, fn i, a -> put_elem(a, i, elem(a, i) + xj) end)
      end)

    Enum.all?(0..(m - 1), fn i -> elem(totals, i) == elem(targets, i) end)
  end

  def part_2(input) do
    input |> parse_input() |> Enum.map(fn {_, _, j, bs} -> solve_machine(j, bs) end) |> Enum.sum()
  end
end
