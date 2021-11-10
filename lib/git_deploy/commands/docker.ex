defmodule GitDeploy.Commands.Docker do
  alias GitDeploy.Commands.Shell

  def files(path) do
    Path.join(path, "docker-compose*.yaml")
    |> Path.wildcard()
    |> Enum.map(&Path.basename/1)
  end

  def stop(path, files) do
    Shell.run("cd #{path}; docker-compose #{dash_f(files)} stop --timeout 30")
  end

  def kill(path, files) do
    Shell.run("cd #{path}; docker-compose #{dash_f(files)} kill")
  end

  def rm(path, files) do
    Shell.run("cd #{path}; docker-compose #{dash_f(files)} rm --force")
  end

  def start(path, files) do
    Shell.run("cd #{path}; docker-compose #{dash_f(files)} start --remove-orphans")
  end

  defp dash_f(files) do
    files
    |> Enum.map(fn x -> "-f #{x}" end)
    |> Enum.join(" ")
  end
end
