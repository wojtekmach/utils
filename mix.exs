defmodule Utils.MixProject do
  use Mix.Project

  def project do
    [
      app: :utils,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:crypto]
    ]
  end
end
