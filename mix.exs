defmodule Bs.Mixfile do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [app: :bs,
     version: @version,
     elixir: "~> 1.5",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: preferred_cli_env(),
     test_coverage: [tool: ExCoveralls],
     erlc_options: erlc_options(Mix.env),
     dialyzer: dialyzer(),
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Bs, []},
     extra_applications: extra_applications(Mix.env)]
  end

  def erlc_options(_all) do
    [:debug_info]
  end

  def extra_applications(:dev) do
    [:mix|
     extra_applications(:all)]
  end

  def extra_applications(_all) do
    [:logger,
     :mnesia]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  def preferred_cli_env do
    [
      vcr: :test,
      "vcr.delete": :test,
      "vcr.check": :test,
      "vcr.show": :test,
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:apex, "~> 0.7"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.8", only: [:dev, :text], runtime: false},
      {:dbg, github: "fishcakez/dbg"},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:distillery, "~> 1.1"},
      {:ecto, "~> 2.0"},
      {:edeliver, "~> 1.4"},
      {:ex_machina, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.6", only: :test},
      {:exvcr, "~> 0.8", only: :test, runtime: false},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 0.11"},
      {:phoenix, "~> 1.3"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.9"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:poison, "~> 3.0"},
      {:proper, github: "manopapad/proper", only: :test},
      {:reprise, "~> 0.5.0", only: :dev},
    ]
  end

  defp dialyzer do
    [plt_add_deps: :apps_direct,
     plt_add_apps: [
       :mnesia,
       :plug],
     flags: [
       "-Wunmatched_returns",
       "-Werror_handling",
       "-Wrace_conditions",
       "-Wunderspecs"]]
  end

  defp aliases do
    [setup: [
        &check_prereqs/1,
        &npm_install/1,
        "deps.get",
        "compile",
        "bs.schema",
        &test/1],

     "bs.schema": [
       "bs.schema.drop",
       "bs.schema.install"]]
  end

  defp npm_install(_) do
    Mix.shell.cmd("npm install")
  end

  def test(_) do
    Mix.shell.cmd("MIX_ENV=test mix test")
  end

  def check_prereqs(_) do
    prereq("sass")
    prereq("npm")
  end

  def prereq(cmd) do
    if Mix.shell.cmd("command -v #{cmd} >/dev/null 2>&1") != 0,
      do: Mix.raise("#{cmd} is required, but could not be found. Aborting.")
  end
end
