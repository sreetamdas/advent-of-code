defmodule AdventOfCode.Helpers do
  def file_input(path) do
    path
    |> File.read!()
  end
end
