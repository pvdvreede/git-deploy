defmodule GitDeploy.Application do
  use Application

  def start(_start_type, _start_args) do
    repo = Application.fetch_env!(:git_deploy, :repo)

    children = [
      {GitDeploy.Server.Repo, {repo[:url], repo[:path], repo[:branch]}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
