defmodule GitDeploy.Repo do
  require Logger
  alias GitDeploy.Commands.Git

  defstruct [
    :url,
    :path,
    :cloned,
    :branch,
    :errors,
    :halted,
    :changed,
    :deployed
  ]

  def new(url) do
    %__MODULE__{
      url: url,
      halted: false,
      deployed: false,
      cloned: false,
      changed: false,
      errors: []
    }
  end

  def update(repo) do
    update(repo, repo.path, repo.branch)
  end

  def update(repo, path, branch) do
    cond do
      File.dir?(path) && not Git.repo?(path) ->
        %{
          repo
          | halted: true,
            errors: repo.errors ++ ["Dir #{path} already exists, but is not a git repo."]
        }

      File.dir?(path) ->
        Logger.info("Updating repo in #{path}...")

        with {:ok, old_sha} <- Git.sha(path),
             :ok <- Git.checkout(path, branch),
             :ok <- Git.pull(path),
             {:ok, new_sha} <- Git.sha(path) do
          %{repo | path: path, branch: branch, cloned: false, changed: old_sha != new_sha}
        end

      true ->
        Logger.info("Cloning repo to #{path}...")

        with :ok <- Git.clone(repo.url, path),
             :ok <- Git.checkout(path, branch) do
          %{repo | path: path, branch: branch, cloned: true, changed: true}
        end
    end
  end

  def decrypt(%{halted: true} = r, _) do
    r
  end

  def decrypt(repo, nil), do: repo

  def decrypt(repo, _passphrase) do
    Logger.info("Decrypting repo in #{repo.path}...")
    repo
  end

  def deploy(%{halted: true} = r, _) do
    r
  end

  def deploy(%{changed: false} = repo, false) do
    Logger.info("No repo changes for #{repo.path}, so not deploying.")
    repo
  end

  def deploy(repo, _force) do
    Logger.info("Deploying #{repo.path}...")
    %{repo | deployed: true}
  end

  def check_errors(%{errors: []} = repo) do
    Logger.info("Update complete for #{repo.path}.")
    repo
  end

  def check_errors(%{errors: errors} = repo) do
    Logger.error("The following errors occured during deployment: #{errors}")
    repo
  end
end
