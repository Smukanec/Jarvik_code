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

## Running Jarvik

Activate the environment and start all services:

```bash
bash run_jarvik.sh
```

## Uninstall

To stop running services and remove generated files and aliases run:

```bash
bash uninstall_jarvik.sh
```

This stops running processes (Ollama, Mistral and Flask), removes the
`venv/` and `memory/` directories and cleans the Jarvik aliases from
`~/.bashrc`.
