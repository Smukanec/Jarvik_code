# Jarvik

This repository contains scripts to run the Jarvik assistant locally. By default
all helper scripts use the `mistral` model from Ollama, but you can override the
model by setting the `MODEL_NAME` environment variable.

## Installation

Install dependencies and create the virtual environment:

```bash
bash install_jarvik.sh
```

Make sure the commands `ollama`, `curl`, `lsof` and either `ss` (from
`iproute2`) or `nc` (from `netcat`) are available on your system.

If you need a fresh start, run the installer with `--clean` to first remove
any previous environment:

```bash
bash install_jarvik.sh --clean
```

After installation, add handy shell aliases by executing `load.sh`:

```bash
bash load.sh
```

This will append alias commands such as `jarvik-start`, `jarvik-status`,
`jarvik-model` and `jarvik-flask` to your `~/.bashrc` and reload the file.

## Starting Jarvik

To launch all components run:

```bash
bash start_jarvik_mistral.sh
```

The script checks for required commands and automatically downloads the
`mistral` model if it is missing. Po spuštění vypíše, zda se všechny části
správně nastartovaly, případné chyby hledejte v souborech `*.log`.
With the aliases loaded you can simply type:

```bash
jarvik-start
```

### Running with a different model

All management scripts now fully honour the `MODEL_NAME` environment variable.
The Flask API will query whichever model is specified. To start Jarvik with any
model simply set the variable when invoking the script. For example:

```bash
MODEL_NAME="mistral:7b-Q4_K_M" bash start_jarvik_mistral.sh
```
Alternatively you can run the dedicated wrapper script:

```bash
bash start_Mistral_7B.sh
# or using the alias
jarvik-start-7b
```

### Starting only the model

When you just need the model running without Flask, use:

```bash
bash start_model.sh
```

With aliases loaded this is simply:

```bash
jarvik-model
```

### Starting only the Flask server

When the model is already running you can launch just the Flask API:

```bash
source venv/bin/activate && python main.py
# or using the alias
jarvik-flask
```

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
starts Flask you can also use the main start script:

```bash
bash start_jarvik_mistral.sh
```

## Real-time Monitoring

To continuously watch Jarvik's state and recent logs, run:

```bash
bash monitor.sh
```

The script refreshes every two seconds and shows the last lines from
`flask.log`, `<model>.log` and `ollama.log` produced by `start_jarvik_mistral.sh`.

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
bash upgrade.sh
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

