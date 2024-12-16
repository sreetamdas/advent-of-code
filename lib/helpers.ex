defmodule AdventOfCode.Helpers do
  def file_input(path) do
    path
    |> File.read!()
  end

  def plop([year, day]) do
    [File.cwd!(), year]
    |> Path.join()
    |> then(fn folder_path ->
      folder_path
      |> File.mkdir_p()
      |> case do
        {:error, reason} ->
          Mix.shell().error(reason)

        :ok ->
          ["input_#{day}.txt", "day_#{day}.exs"]
          |> Enum.map(&Path.join([folder_path, &1]))
          |> Enum.each(&File.touch!/1)
      end
    end)
  end
end
