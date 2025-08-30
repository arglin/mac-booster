-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.plugins = {
  "mfussenegger/nvim-jdtls",
  -- lazy.nvim
  -- {
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     -- add any options here
  --   },
  --   dependencies = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --   }
 -- },
  { "Pocco81/AutoSave.nvim" },
  { "nvim-treesitter/nvim-treesitter-angular" }
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })


lvim.builtin.treesitter.ensure_installed = {
  "java",
}

require("lvim.lsp.manager").setup("angularls")

-- require("noice").setup({
--   lsp = {
--     -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
--     override = {
--       ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
--       ["vim.lsp.util.stylize_markdown"] = false,
--       ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
--     },
--   },
--   -- you can enable a preset for easier configuration
--   presets = {
--     bottom_search = true,         -- use a classic bottom cmdline for search
--     command_palette = false,      -- position the cmdline and popupmenu together
--     long_message_to_split = true, -- long messages will be sent to a split
--     inc_rename = false,           -- enables an input dialog for inc-rename.nvim
--     lsp_doc_border = false,       -- add a border to hover docs and signature help
--   },
-- })

--[[ -- AutoSave configuration
require('autosave').setup(
  {
    enabled = true,
    execution_message = "AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"),
    events = {"InsertLeave", "TextChanged"},
    conditions = {
      exists = true,
      filetype_is_not = {},
      modifiable = true,
    },
    write_all_buffers = true,
    on_off_commands = true,
    clean_command_line_interval = 2500,
    debounce_delay = 135
  }
)
]]
vim.opt.wrap = true
vim.opt.showtabline = 0
vim.opt.nu = true
vim.opt.rnu = true
vim.o.statuscolumn = "%s %l %r "
