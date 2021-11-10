defmodule GitDeploy.Server.Repo do
  alias GitDeploy.Repo
  use GenServer

  def start_link({url, path, branch}) do
    GenServer.start_link(__MODULE__, {url, path, branch}, name: __MODULE__)
  end

  def init({url, path, branch}) do
    r =
      Repo.new(url)
      |> Repo.update(path, branch)
      |> Repo.check_errors()

    timer = Process.send_after(self(), :deploy, 60_000)
    {:ok, %{timer: timer, repo: r}}
  end

  def handle_info(:deploy, %{repo: repo} = state) do
    repo
    |> Repo.update()
    |> Repo.deploy(false)
    |> Repo.check_errors()

    timer = Process.send_after(self(), :deploy, 60_000)
    {:noreply, %{state | timer: timer, repo: repo}}
  end
end
