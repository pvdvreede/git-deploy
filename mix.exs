defmodule GitDeploy.MixProject do
  use Mix.Project

  def project do
    [
      app: :git_deploy,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications
  def application do
    [
      extra_applications: [:logger]
      # mod: {GitDeploy.Application, nil}
    ]
  end

  defp deps do
    []
  end
end
