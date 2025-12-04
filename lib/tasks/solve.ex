defmodule Mix.Tasks.Solve do
  @moduledoc """
  Solve for a given year and day
  """
  alias AdventOfCode.Helpers
  use Mix.Task

  @impl Mix.Task
  def run([year, day]) do
    code_file =
      Path.join([File.cwd!(), year, "day_#{String.pad_leading(day, 2, "0")}.exs"])

    if File.exists?(code_file) do
      input = AdventOfCode.Helpers.file_input(code_file)
      [{module, _}] = Code.require_file(code_file)
      part_1 = module.part_1(input)
      part_2 = module.part_2(input)

      IO.puts(
        "\n\n### #{year} day_#{day} ###\n\npart_1: #{part_1}\npart_2: #{part_2}\n\nBenchmarking..."
      )

      Helpers.bench(module, input)
    else
      Mix.shell().error("File not found: #{code_file}")
    end
  end
end
