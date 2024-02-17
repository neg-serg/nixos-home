-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ neovim/nvim-lspconfig                                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'neovim/nvim-lspconfig',
    config = function()
        vim.diagnostic.config({
            virtual_text=true,
            signs=true,
            underline=true,
            update_in_insert=false,
            severity_sort=false,
        })
        local signs={Error="", Warn="", Hint="", Info=""}
        for type, icon in pairs(signs) do
            local hl="DiagnosticSign" .. type
            vim.fn.sign_define(hl, {text=icon, texthl=hl, numhl=hl})
        end

        local lspconfig = require('lspconfig')
        lspconfig.bashls.setup{}
        lspconfig.clangd.setup{}
        lspconfig.nil_ls.setup{}
        lspconfig.pyright.setup{}
    end,
}
