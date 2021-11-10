defmodule GitDeploy.Commands.Command do
  @callback run(cmd :: String.t()) :: {String.t(), non_neg_integer()}
  @callback run(cmd :: String.t(), stdin :: String.t() | none()) ::
              {String.t(), non_neg_integer()}
end

defmodule GitDeploy.Commands.Shell do
  @behaviour GitDeploy.Commands.Command

  @impl true
  def run(cmd) do
    run(cmd, nil)
  end

  @impl true
  def run(cmd, nil) do
    {out, ret} = System.shell(cmd, into: "", stderr_to_stdout: true)
    {String.trim(out), ret}
  end

  @impl true
  def run(cmd, stdin) do
    run("echo \"#{stdin}\" | #{cmd}", nil)
  end
end
