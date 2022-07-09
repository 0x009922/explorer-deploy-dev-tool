defmodule Util do
  def cargo_install_from_git(repo, crate, params) do
    {cargo_root, params} = Keyword.pop!(params, :root)
    params = Enum.reduce(params, [], fn {k, v}, acc -> acc ++ ["--#{k}", v] end)

    System.cmd(
      "cargo",
      [
        "install",
        crate,
        "--root",
        cargo_root,
        "--git",
        repo
      ] ++ params,
      into: IO.stream()
    )
  end

  def copy_cargo_bin_into_dir(root, bin, dir) do
    File.cp!(Path.join([root, "bin", bin]), Path.join(dir, bin))
  end

  def ensure_dir(dir) do
    cond do
      not File.exists?(dir) -> File.mkdir_p!(dir)
      not File.dir?(dir) -> raise "File #{dir} exists, but it is not a directory. Please fix it."
      true -> nil
    end
  end
end

config = %{
  cargo_root: "./.tmp-cargo",
  configs_dir: "./configs",
  iroha_dir: "./.iroha",
  explorer_dir: "./.explorer",
  bin_iroha: "iroha",
  bin_explorer: "iroha2_explorer_web"
}

case System.argv() do
  ["config"] ->
    [config.iroha_dir, config.explorer_dir]
    |> Enum.each(&Util.ensure_dir/1)

    File.copy!(
      Path.join(config.configs_dir, "client_config.json"),
      Path.join(config.explorer_dir, "client_config.json")
    )

    File.copy!(
      Path.join(config.configs_dir, "iroha_config.json"),
      Path.join(config.iroha_dir, "config.json")
    )

    File.copy!(
      Path.join(config.configs_dir, "iroha_genesis.json"),
      Path.join(config.iroha_dir, "genesis.json")
    )

    IO.puts("Configurations are copied")

  ["install" | tail] ->
    case tail do
      ["iroha"] ->
        IO.puts("Installing Iroha")

        Util.cargo_install_from_git(
          "https://github.com/hyperledger/iroha.git",
          config.bin_iroha,
          rev: "75da907f66d5270f407a50e06bc76cec41d3d409",
          root: config.cargo_root
        )

        Util.ensure_dir(config.iroha_dir)

        Util.copy_cargo_bin_into_dir(
          config.cargo_root,
          config.bin_iroha,
          config.iroha_dir
        )

      ["explorer"] ->
        IO.puts("Installing explorer")

        Util.cargo_install_from_git(
          "https://github.com/soramitsu/iroha2-block-explorer-backend.git",
          config.bin_explorer,
          branch: "feat/new-web-methods",
          root: config.cargo_root
        )

        Util.ensure_dir(config.explorer_dir)

        Util.copy_cargo_bin_into_dir(
          config.cargo_root,
          config.bin_explorer,
          config.explorer_dir
        )

      _ ->
        IO.puts("I can only install explorer or iroha")
    end

  ["run" | tail] ->
    case tail do
      ["iroha"] ->
        System.shell(
          "./iroha --submit-genesis",
          cd: config.iroha_dir,
          into: IO.stream()
        )

      ["explorer"] ->
        System.shell(
          "./iroha2_explorer_web",
          cd: config.explorer_dir,
          into: IO.stream()
        )

      _ ->
        IO.puts("I can only run explorer or iroha")
    end

  _ ->
    script = "elixir ./assistant.exs"

    IO.puts("""
        Hi!

        I am here to help you with explorer & iroha deployment

        1. Install Iroha & Explorer:

          #{script} install iroha
          #{script} install exporer


        2. Copy configuration files:

          #{script} config

        3. Run them!

          #{script} run iroha
          #{script} run explorer

        Check out http://localhost:4000/api/v1 !
    """)
end
