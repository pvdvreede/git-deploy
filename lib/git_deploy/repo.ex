defmodule GitDeploy.Repo do
  defstruct [
    :url,
    :path,
    :cloned,
    :branch,
    :passphrase,
    :errors,
    :halted,
    :changed
  ]

  def new(url) do
    %__MODULE__{
      url: url,
      halted: false,
      cloned: false
    }
  end

  def clone(repo, path) do
    case System.cmd("git", ["clone", repo.url, path]) do
      {_, 0} ->
        %{repo | path: path, cloned: true, halted: false, changed: true}

      {err, _} ->
        %{repo | errors: repo.errors ++ [Enum.join(err, " ")], halted: true}
    end
  end

  def checkout(%{branch: b1} = r, b2) when b1 == b2, do: r

  def checkout(%{cloned: false} = r, _),
    do: %{r | errors: r.errors ++ ["Cant checkout if not cloned."]}

  def checkout(%{path: path} = repo, branch) do
    case System.cmd("git", ["-C", path, "checkout", branch]) do
      {_, 0} ->
        %{repo | branch: branch, changed: true}

      {err, _} ->
        %{repo | errors: repo.errors ++ [err], halted: true}
    end
  end

  def update(repo) do
    {:ok, prev_sha} = sha(repo)

    case System.cmd("git", ["-C", repo.path, "pull", "origin", repo.branch]) do
      {_, 0} ->
        {:ok, current_sha} = sha(repo)
        %{repo | changed: current_sha != prev_sha}

      {err, _} ->
        %{repo | errors: repo.errors ++ [err], halted: true}
    end
  end

  def decrypt(repo, ""), do: repo
  def decrypt(repo, nil), do: repo

  def decrypt(repo, passphrase) do
    with tmpdir <- System.tmp_dir!(),
         creds_path <- Path.join(tmpdir, "creds_tmp"),
         :ok <- File.write(creds_path, passphrase),
         {_, 0} <- System.cmd("git", ["-C", repo.path, "crypt", "unlock", creds_path]),
         :ok <- File.rm(creds_path) do
      repo
    end
  end

  def sha(%{cloned: false}), do: {:error, "Not cloned out yet."}

  def sha(repo) do
    case System.cmd("git", ["-C", repo.path, "rev-parse", "HEAD"]) do
      {sha, 0} -> {:ok, String.trim(sha)}
      {err, _} -> {:error, err}
    end
  end
end
