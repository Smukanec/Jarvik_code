# Jarvik

This repository contains scripts to run the Jarvik assistant locally.

## Installation

Install dependencies and create the virtual environment:

```bash
bash install_jarvik.sh
```

If you need a fresh start, run the installer with `--clean` to first remove
any previous environment:

```bash
bash install_jarvik.sh --clean
```

After installation, add handy shell aliases by executing `load.sh`:

```bash
bash load.sh
```

This will append alias commands such as `jarvik-start` and `jarvik-status`
to your `~/.bashrc` and reload the file.

## Starting Jarvik

To launch all components run:

```bash
bash start.sh
```

The script checks for required commands and automatically downloads the
model specified in `MODEL_NAME` (defaults to `mistral`) if it is missing.
Po spuštění vypíše, zda se všechny části správně nastartovaly, případné
chyby hledejte v souborech `*.log`.
With the aliases loaded you can simply type:

```bash
jarvik-start
```

### Running with a different model

All management scripts honour the `MODEL_NAME` environment variable. The Flask
API will query whichever model is specified. To start Jarvik with another model
set the variable when invoking the script:

```bash
MODEL_NAME="mistral:7b-Q4_K_M" bash start.sh  # run with a different model
```

All provided scripts now fully honour this variable.

## Checking Status

See which services are running using:

```bash
bash status.sh
```

or via the alias:

```bash
jarvik-status
```
The script expects the selected model to be running persistently via
`ollama run $MODEL_NAME`.

## Stopping Jarvik and Uninstall

Jarvik can be stopped and fully removed using the uninstall script:

```bash
bash uninstall_jarvik.sh
```

The script stops Ollama, Mistral and Flask, removes the `venv/` and
`memory/` directories and cleans the Jarvik aliases from `~/.bashrc`.

## Quick Start Script

For a single command that activates the environment, loads the model and
starts Flask you can also use:

```bash
bash run_jarvik.sh
```

## Real-time Monitoring

To continuously watch Jarvik's state and recent logs, run:

```bash
bash monitor.sh
```

The script refreshes every two seconds and shows the last lines from
`flask.log`, `<model>.log` and `ollama.log` produced by `start.sh`.

## Automatic Restart

If any component stops running, you can launch a watchdog that will
restart missing processes automatically:

```bash
bash watchdog.sh
```

The watchdog checks every five seconds that Ollama, the Mistral model and
the Flask server are up and restarts them when needed.

## Upgrade

To download the latest version, reinstall and start Jarvik automatically run:

```bash
bash upgrade.sh  # nebo update.sh
```

The script pulls the newest repository files, performs an uninstall, installs the dependencies again, reloads the shell aliases and starts all components.

## API Usage

Jarvik exposes a few HTTP endpoints on port `8010` that can be consumed by
external applications such as ChatGPT:

* `POST /ask` – ask Jarvik a question. The conversation is stored in memory.
* `POST /memory/add` – manually append a `{ "user": "...", "jarvik": "..." }`
  record to the memory log.
* `GET /memory/search?q=term` – search stored memory entries. When no query is
  provided, the last five entries are returned.
* `GET /knowledge/search?q=term` – search the local knowledge base files.

## License

This project is licensed under the [MIT License](LICENSE).

