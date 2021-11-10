defmodule GitDeploy.Commands.Git do
  alias GitDeploy.Commands.Shell

  def clone(url, path) do
    case Shell.run("git clone #{url} #{path}") do
      {_, 0} -> :ok
      {err, _} -> {:error, err}
    end
  end

  def pull(path) do
    case Shell.run("git -C #{path} pull -r") do
      {_, 0} -> :ok
      {err, _} -> {:error, err}
    end
  end

  def unlock(path, passphrase) do
    case Shell.run("git -C #{path} crypt unlock -", passphrase) do
      {_, 0} -> :ok
      {err, _} -> {:error, err}
    end
  end

  def checkout(path, branch) do
    case Shell.run("git -C #{path} checkout #{branch}") do
      {_, 0} -> :ok
      {err, _} -> {:error, err}
    end
  end

  def sha(path) do
    case Shell.run("git -C #{path} rev-parse HEAD") do
      {sha, 0} -> {:ok, sha}
      {err, _} -> {:error, err}
    end
  end

  def repo?(path) do
    case Shell.run("git -C #{path} rev-parse --git-dir") do
      {_, 0} -> true
      {_, _} -> false
    end
  end
end
