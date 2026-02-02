# Notebook Workflow (Neovim + Molten)

This setup provides a Jupyter-like workflow inside Neovim using:
- Molten (Jupyter kernel + outputs)
- NotebookNavigator (cell navigation and run helpers)
- Jupytext (optional: convert between .ipynb and .py)

Localleader is `,` (comma).

## Dependencies

### Python (required)
Install these in the same Python environment you use for Neovim:
```bash
pip install pynvim jupyter_client
```

If you want to convert notebooks to scripts and back:
```bash
pip install jupytext
```

### Remote plugin setup (Molten)
After installing/updating Molten:
1) Run `:UpdateRemotePlugins`
2) Restart Neovim

## File format and cells

Use the percent format:
```
# %%
print("cell 1")

# %%
print("cell 2")
```

Markdown cells follow Jupytext rules:
```
# %% [markdown]
# This is markdown
# - list item
```

## Notebook keybindings (Python buffers)

Run:
- `,r` run current cell (skips markdown cells)
- `,c` run current cell and move to next (markdown cells are skipped)
- `,R` restart kernel, clear outputs, run all code cells
- `,u` restart kernel, clear outputs, run from first cell to current code cell

Cell management:
- `,j` insert cell below
- `,k` insert cell above
- `,m` mark current cell as markdown (adds `[markdown]` and prefixes lines with `#`)

Navigation:
- `,[` previous cell
- `,]` next cell

Outputs:
- `,z` clear current cell output
- `,Z` clear all outputs

## Jupytext conversion wrapper

A wrapper script is provided:
```
jtext example.ipynb
jtext example.py
```

It will create the paired file and sync outputs/metadata.

Script location: `dotfiles/scripts/jtext`
Alias: `jtext` (from `dotfiles/zsh/conf.d/04_alias.conf`)

## Tips

- If outputs do not appear, run `:UpdateRemotePlugins` and restart.
- Markdown cells are not executed; run commands ignore them.
- For images, use Kitty and ensure ImageMagick is installed.
