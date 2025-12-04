defmodule AdventOfCode.Helpers do
  alias Benchee

  def file_input(file) do
    day =
      file
      |> Path.basename()
      |> String.split("_")
      |> Enum.at(1)
      |> String.replace(".exs", "")

    file
    |> Path.dirname()
    |> Path.join("input_#{day}.txt")
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
          day
          |> String.pad_leading(2, "0")
          |> then(&["input_#{&1}.txt", "day_#{&1}.exs"])
          |> Enum.map(&Path.join([folder_path, &1]))
          |> Enum.each(&File.touch!/1)
      end
    end)
  end

  def bench(module, _inputs = prod) do
    Benchee.run(
      %{
        "part_1" => &module.part_1/1,
        "part_2" => &module.part_2/1
      },
      warmup: 2,
      time: 3,
      memory_time: 2,
      print: [benchmarking: false, configuration: false],
      inputs: %{
        # test: test,
        prod: prod
      }
    )
  end
end
