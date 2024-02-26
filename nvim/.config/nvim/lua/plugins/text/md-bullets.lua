-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ cstsunfu/md-bullets.nvim                                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'cstsunfu/md-bullets.nvim', -- markdown org-like bullets(better highlighting)
        enabled=false,
        config=function() 
            local ok, bullets = pcall(require, 'md-bullets')
            if (not ok) then return end
            bullets.setup {
                symbols={"◉","○","✸","✿"}
            }
        end}
