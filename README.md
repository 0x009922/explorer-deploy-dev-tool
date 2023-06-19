# Explorer Deploy Assistant

This is a deploy assistant for setting up Iroha and Explorer using Elixir. It helps automate the installation and configuration process. Please ensure that you have the following prerequisites before running the assistant:

## Prerequisites

- [Elixir](https://elixir-lang.org/install.html) (v1.14.0) is installed on your system.
- You are using a Linux environment, preferably Ubuntu.

## Running the Assistant

To run the assistant, execute the following command in your terminal:

```bash
elixir ./assistant.exs 
```

This will display the help message, guiding you through the available commands and options.

## Setup Steps

Follow these steps to install and configure Iroha and Explorer using the assistant:

1. Install Iroha and Explorer:

```bash
elixir ./assistant.exs install iroha
elixir ./assistant.exs install explorer
```

This will download and install the necessary components for Iroha and Explorer.

2. Copy Configuration Files:
```bash
elixir ./assistant.exs config
```
This command will copy the configuration files required for Iroha and Explorer.

3. Run Iroha and Explorer:
```bash
elixir ./assistant.exs run iroha
elixir ./assistant.exs run explorer
```

Start the Iroha and Explorer services using these commands.

4. Access the Explorer API:

Once the services are running, you can access the Explorer API by visiting [http://localhost:4000/api/v1](http://localhost:4000/api/v1) in your web browser.



**Note:** The assistant uses rc9 of Iroha as of this version.
