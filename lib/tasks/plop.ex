defmodule Mix.Tasks.Plop do
  @moduledoc """
  Plop files for new solution
  """
  use Mix.Task
  alias AdventOfCode.Helpers

  @impl Mix.Task
  def run(args) do
    # Mix.shell().info(Enum.join(args, "-"))
    Helpers.plop(args)
  end
end
