# Jarvik

This repository contains scripts to run the Jarvik assistant locally. By default
all helper scripts use the `gemma:2b` model from Ollama, but you can override
the model by setting the `MODEL_NAME` environment variable.
Jarvik keeps the entire conversation history unless you set the
`MAX_MEMORY_ENTRIES` environment variable to limit how many exchanges are stored.
The Flask API listens on port `8010` by default, but you can override this using
the `FLASK_PORT` environment variable.

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
`jarvik-model`, `jarvik-flask`, `jarvik-ollama`, `jarvik-start-7b` and
`jarvik-start-q4` to your `~/.bashrc` and reload the file. The `jarvik-start`
alias launches the default Gemma 2B model.

PDF and DOCX knowledge base files are supported when the optional packages
`PyPDF2` and `python-docx` are installed. These are listed as extras in
`requirements.txt`.

### Text-only mode

If you only work with plain text files you can simplify Jarvik:

1. Edit `static/index.html` so the file input uses `accept=".txt"`.
2. Remove the `.pdf` and `.docx` branches from the `/ask_file` handler in
   `main.py`.

After these changes Jarvik will only process TXT files and you may remove the
`PyPDF2` and `python-docx` packages from your environment.

## Starting Jarvik

To launch all components run:

```bash
bash start_jarvik.sh
```

The script checks for required commands and automatically downloads the
`gemma:2b` model if it is missing. Po spuštění vypíše, zda se všechny části
správně nastartovaly, případné chyby hledejte v souborech `*.log`.
With the aliases loaded you can simply type:

```bash
jarvik-start
```

The default model is **Gemma&nbsp;2B**. The web UI includes a selector
right under the logo for choosing another model. Selecting a value and
pressing **Přepnout model** calls the `/model` endpoint which restarts
Jarvik with the chosen model.

### Running with a different model

All management scripts now fully honour the `MODEL_NAME` environment variable.
The Flask API will query whichever model is specified. To start Jarvik with any
model simply set the variable when invoking the script. For example:

```bash
MODEL_NAME="mistral:7b-Q4_K_M" bash start_jarvik.sh
```
Alternatively you can run the dedicated wrapper scripts:

```bash
# Default model
bash start_Gemma_2B.sh
# or using the alias
jarvik-start

# Mistral 7B model
bash start_Mistral_7B.sh
# or using the alias
jarvik-start-7b
# (available after running `bash load.sh`)
```

Switching models is seamless because each wrapper calls `stop_all.sh` before
starting the selected model. Any running model or Flask instance is
terminated automatically. To switch from the command line at any time use

```bash
bash switch_model.sh mistral:7b-Q4_K_M
```

which restarts Jarvik with the chosen model using the same `/model` endpoint
as the web UI.

Another helper script starts a pre-quantized Q4 model:

```bash
bash start_Jarvik_Q4.sh
# or using the alias
jarvik-start-q4
# (available after running `bash load.sh`)
```

### Offline usage

If you need to run without internet access, first download the model file (for
example using `stahni-mistral-q4.sh`). Create a `Modelfile` that references the
downloaded `.gguf` file and register it with:

```bash
ollama create mistral:7b-Q4_K_M -f Modelfile
```

When you set `LOCAL_MODEL_FILE` to the path of your local model, the start
scripts will create the Ollama model automatically.

### Starting only Ollama

When you want just the Ollama service without loading a model, run:

```bash
bash start_ollama.sh
```

With aliases loaded this is simply:

```bash
jarvik-ollama
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

When the model is already running you can launch just the Flask API using the
new helper script or manually:

```bash
bash start_flask.sh
# or manually
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

You can check multiple models at once by listing them as arguments or
via the `MODEL_NAMES` environment variable:

```bash
MODEL_NAMES="mistral jarvik-q4" bash status.sh
```

## Stopping Jarvik and Uninstall

Jarvik can be stopped and fully removed using the uninstall script:

```bash
bash uninstall_jarvik.sh
```

The script stops Ollama, the model and Flask, removes the `venv/` and
`memory/` directories and cleans the Jarvik aliases from `~/.bashrc`.

To merely stop the running services without removing anything, execute:

```bash
bash stop_all.sh
```

## Quick Start Script

For a single command that activates the environment, loads the model and
starts Flask you can also use the main start script:

```bash
bash start_jarvik.sh
```

## Real-time Monitoring

To continuously watch Jarvik's state and recent logs, run:

```bash
bash monitor.sh
```

The script refreshes every two seconds and shows the last lines from
`flask.log`, `<model>.log` and `ollama.log` produced by `start_jarvik.sh`.

## Automatic Restart

If any component stops running, you can launch a watchdog that will
restart missing processes automatically:

```bash
bash watchdog.sh
```

The watchdog checks every five seconds that Ollama, the Gemma 2B model and
the Flask server are up and restarts them when needed.

## Upgrade

To download the latest version, reinstall and start Jarvik automatically run:

```bash
bash upgrade.sh
```

The script pulls the newest repository files, performs an uninstall, installs the dependencies again, reloads the shell aliases and starts all components.

## API Usage

Jarvik exposes a few HTTP endpoints on the configured Flask port
(default `8010`) that can be consumed by external applications such as ChatGPT:

* `POST /ask` – ask Jarvik a question. The conversation is stored in memory.
* `POST /memory/add` – manually append a `{ "user": "...", "jarvik": "..." }`
  record to the memory log.
* `GET /memory/search?q=term` – search stored memory entries. When no query is
  provided, the last five entries are returned.
* `GET /knowledge/search?q=term` – search the local knowledge base files.
* `GET /model` – return the name of the currently active model.
* `POST /model` – restart Jarvik with a new model, e.g. `{"model": "mistral"}`.

## License

This project is licensed under the [MIT License](LICENSE).

