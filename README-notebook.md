# Notebook workflow (Neovim)

A Jupyter-like workflow inside Neovim.

## Stack

- Molten (Jupyter kernel + outputs)
- NotebookNavigator (cell navigation/run helpers)
- Jupytext (optional: `.ipynb` ⇄ percent-format `.py`)

Localleader is `,`.

## Dependencies

Install in the same Python env Neovim uses:

```bash
pip install pynvim jupyter_client
```

Optional:

```bash
pip install jupytext
```

After installing/updating Molten:

- run `:UpdateRemotePlugins`
- restart Neovim

## Cell format

Percent format:

```python
# %%
print("cell 1")

# %%
print("cell 2")
```

Markdown cells:

```python
# %% [markdown]
# This is markdown
```

## Keybindings (Python buffers)

- `,r` run current cell (skips markdown)
- `,c` run current cell and move to next
- `,R` restart kernel, clear outputs, run all code cells
- `,u` restart kernel, clear outputs, run from first to current

Navigation:
- `,[` previous cell
- `,]` next cell

Outputs:
- `,z` clear current cell output
- `,Z` clear all outputs

## jtext helper

Wrapper script:

```bash
jtext example.ipynb
jtext example.py
```

Location: `dotfiles/scripts/jtext`
