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

With the aliases loaded you can simply type:

```bash
jarvik-start
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
The script expects the Mistral model to be running persistently via
`ollama run mistral`.

## Stopping Jarvik and Uninstall

Jarvik can be stopped and fully removed using the uninstall script from
Issue 1:

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
