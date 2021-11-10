defmodule GitDeploy do
  alias GitDeploy.Repo

  def deploy(url, path, branch, force \\ false, passphrase \\ nil) do
    Repo.new(url)
    |> Repo.update(path, branch)
    |> Repo.decrypt(passphrase)
    |> Repo.deploy(force)
    |> Repo.check_errors()
  end
end
