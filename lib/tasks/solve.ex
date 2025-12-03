defmodule Mix.Tasks.Solve do
  @moduledoc """
  Solve for a given year and day
  """
  use Mix.Task

  @impl Mix.Task
  def run([year, day]) do
    code_file =
      Path.join([File.cwd!(), year, "day_#{String.pad_leading(day, 2, "0")}.exs"])

    if File.exists?(code_file) do
      Code.eval_file(code_file, Path.join([File.cwd!(), year]))
    else
      Mix.shell().error("File not found: #{code_file}")
    end
  end
end
