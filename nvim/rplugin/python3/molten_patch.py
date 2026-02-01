import pynvim


@pynvim.plugin
class MoltenPatch:
    def __init__(self, nvim):
        self.nvim = nvim
        self._patched = False
        self.nvim.vars["molten_patch_loaded"] = 1

    def _apply_patch(self):
        if self._patched:
            return
        try:
            import molten.moltenbuffer as mb
            import molten.outputbuffer as ob
            import molten.outputchunks as oc
        except Exception:
            return

        try:
            self.nvim.exec_lua(
                """
                local ok, mod = pcall(require, "load_image_nvim")
                if ok and mod and mod.image_api and not mod.image_api._safe_clear then
                  local orig_clear = mod.image_api.clear
                  mod.image_api.clear = function(identifier)
                    if identifier == nil then
                      return
                    end
                    local ok2 = pcall(orig_clear, identifier)
                    if not ok2 then
                      return
                    end
                  end
                  mod.image_api._safe_clear = true
                end
                """
            )
        except Exception:
            pass

        if not getattr(mb.MoltenKernel.update_interface, "_show_done_patch", False):
            orig_update = mb.MoltenKernel.update_interface

            def patched_update(self):
                orig_update(self)
                if self.options.virt_text_output:
                    return
                if self.selected_cell is None:
                    return
                if not self.should_show_floating_win:
                    return
                if self.selected_cell in self.outputs:
                    try:
                        self.outputs[self.selected_cell].show_floating_win(self.selected_cell.end)
                    except Exception:
                        pass

            patched_update._show_done_patch = True
            mb.MoltenKernel.update_interface = patched_update

        if not getattr(ob.OutputBuffer.show_floating_win, "_guard_patch", False):
            orig_show = ob.OutputBuffer.show_floating_win

            def patched_show(self, anchor):
                try:
                    return orig_show(self, anchor)
                except Exception:
                    return None

            patched_show._guard_patch = True
            ob.OutputBuffer.show_floating_win = patched_show

        if not getattr(ob.OutputBuffer.clear_float_win, "_clear_img_patch", False):
            orig_clear = ob.OutputBuffer.clear_float_win
            try:
                from molten.outputchunks import ImageOutputChunk
            except Exception:
                ImageOutputChunk = None

            def patched_clear(self):
                try:
                    if ImageOutputChunk is not None:
                        for chunk in self.output.chunks:
                            if isinstance(chunk, ImageOutputChunk) and chunk.img_identifier:
                                ident = chunk.img_identifier
                                if ident.startswith("virt-"):
                                    base = ident[5:]
                                    ids = {ident, base}
                                else:
                                    ids = {ident, "virt-" + ident}
                                for img_id in ids:
                                    try:
                                        self.canvas.remove_image(img_id)
                                    except Exception:
                                        pass
                        try:
                            self.canvas.present()
                        except Exception:
                            pass
                except Exception:
                    pass
                return orig_clear(self)

            patched_clear._clear_img_patch = True
            ob.OutputBuffer.clear_float_win = patched_clear

        if not getattr(oc.ImageOutputChunk.place, "_unique_id_patch", False):
            orig_place = oc.ImageOutputChunk.place

            def patched_place(self, bufnr, options, _col, lineno, _shape, canvas, virtual, winnr=None):
                loc = options.image_location
                if not (loc == "both" or (loc == "virt" and virtual) or (loc == "float" and not virtual)):
                    return "", 0

                ident = f"{'virt-' if virtual else ''}{self.img_path}:{bufnr}:{lineno}"
                self.img_identifier = canvas.add_image(
                    self.img_path,
                    ident,
                    0,
                    lineno,
                    bufnr,
                    winnr,
                )
                return " \n", canvas.img_size(self.img_identifier)["height"]

            patched_place._unique_id_patch = True
            oc.ImageOutputChunk.place = patched_place

        self._patched = True

    @pynvim.autocmd("User", pattern="MoltenInitPost", sync=True)
    def on_molten_init_post(self):
        self._apply_patch()
