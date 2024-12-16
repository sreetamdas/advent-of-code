defmodule Mix.Tasks.Uplift do
  @moduledoc """
  Move files up a folder and rename, for a flatter structure
  """
  use Mix.Task

  @impl Mix.Task
  def run([year]) do
    [File.cwd!(), year]
    |> Path.join()
    |> then(fn folder_path ->
      1..25
      |> Enum.each(fn num ->
        num
        |> Integer.to_string()
        |> String.graphemes()
        |> case do
          x when length(x) == 1 ->
            ["0", x]

          x ->
            x
        end
        |> Enum.join()
        |> then(fn day ->
          [folder_path, "day_#{day}"]
          |> Path.join()
          |> then(fn day_path ->
            day_path
            |> File.dir?()
            |> IO.inspect(label: "#{day} exists")
            |> case do
              true ->
                with :ok <-
                       Path.join([day_path, "input.txt"])
                       |> File.exists?()
                       |> then(fn
                         true ->
                           Path.join([day_path, "input.txt"])
                           |> File.rename(Path.join([folder_path, "input_#{day}.txt"]))

                         false ->
                           :ok
                       end),
                     :ok <-
                       Path.join([day_path, "day_#{day}.exs"])
                       |> File.rename(Path.join([folder_path, "day_#{day}.exs"])),
                     :ok <- File.rmdir(day_path) do
                  IO.puts("day_#{day} uplifted")
                else
                  {:error, reason} -> IO.puts("Error during day_#{day}: #{reason}")
                end

              _ ->
                IO.puts("Folder doesn't exist for day_#{day}, exiting")
            end
          end)
        end)
      end)
    end)
  end
end
