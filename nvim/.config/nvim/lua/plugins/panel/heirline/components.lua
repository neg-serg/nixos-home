return function(ctx)
  local api, fn = ctx.api, ctx.fn
  local c, utils = ctx.c, ctx.utils
  local colors, S = ctx.colors, ctx.S
  local prof, dbg_push = ctx.prof, ctx.dbg_push
  local ok_devicons, devicons = ctx.ok_devicons, ctx.devicons
  local USE_ICONS, SHOW_ENV = ctx.USE_ICONS, ctx.SHOW_ENV
  local is_empty, is_narrow, is_tiny = ctx.is_empty, ctx.is_narrow, ctx.is_tiny
  local align = ctx.align or { provider = '%=' }
  local get_status_win = ctx.statusline_win
  local get_status_buf = ctx.statusline_buf
  local buf_display_name = ctx.buf_name
  local buf_full_path = ctx.buf_path
  local win_cwd = ctx.window_cwd
  local open_file_browser_cwd = ctx.open_file_browser_cwd
  local open_git_ui = ctx.open_git_ui
  local open_diagnostics_list = ctx.open_diagnostics_list
  local safe_buffer_matches = ctx.safe_buffer_matches
  local notify = ctx.notify

  -- ── Window/buffer helpers ─────────────────────────────────────────────────
  local function target_win()
    local win = get_status_win()
    if win and api.nvim_win_is_valid(win) then return win end
    return nil
  end
  local function target_buf()
    local buf = get_status_buf()
    if buf and api.nvim_buf_is_valid(buf) then return buf end
    local win = target_win()
    if win then
      local ok, win_buf = pcall(api.nvim_win_get_buf, win)
      if ok and api.nvim_buf_is_valid(win_buf) then return win_buf end
    end
    return nil
  end
  local function buf_option(bufnr, name, fallback)
    if bufnr and api.nvim_buf_is_valid(bufnr) then
      local ok, val = pcall(api.nvim_buf_get_option, bufnr, name)
      if ok then return val end
    end
    return fallback
  end
  local function win_option(win, name, fallback)
    if win and api.nvim_win_is_valid(win) then
      local ok, val = pcall(api.nvim_win_get_option, win, name)
      if ok then return val end
    end
    return fallback
  end
  local function win_call(win, cb, fallback)
    if win and api.nvim_win_is_valid(win) then
      local ok, res = pcall(api.nvim_win_call, win, cb)
      if ok then return res end
    end
    return fallback
  end

  -- ── Special types (icons) ─────────────────────────────────────────────────
  local FT_ICON = {
    help={'','Help'}, quickfix={'','Quickfix'}, terminal={'','Terminal'}, prompt={'','Prompt'}, nofile={'','Scratch'},
    TelescopePrompt={'','Telescope'}, TelescopeResults={'','Telescope'},
    fzf={'','FZF'}, ['fzf-lua']={'','FZF'}, ['fzf-checkmarks']={'','FZF'},
    ['grug-far']={'󰈞','GrugFar'}, Spectre={'','Spectre'}, spectre_panel={'','Spectre'}, ['spectre-replace']={'','Spectre'},
    NvimTree={'','Explorer'}, ['neo-tree']={'','Neo-tree'}, Neotree={'','Neo-tree'}, ['neo-tree-popup']={'','Neo-tree'},
    oil={'','Oil'}, dirbuf={'','Dirbuf'}, lir={'','Lir'}, fern={'','Fern'}, chadtree={'','CHADTree'},
    defx={'','Defx'}, ranger={'','Ranger'}, vifm={'','Vifm'}, minifiles={'','MiniFiles'}, mf={'','MiniFiles'},
    vaffle={'','Vaffle'}, netrw={'','Netrw'}, explore={'','Explore'}, dirvish={'','Dirvish'}, yazi={'','Yazi'},
    fugitive={'','Fugitive'}, fugitiveblame={'','Git Blame'},
    DiffviewFiles={'','Diffview'}, DiffviewFileHistory={'','Diffview'},
    gitcommit={'','Commit'}, gitrebase={'','Rebase'}, gitconfig={'','Git Config'},
    NeogitCommitMessage={'','Neogit'}, NeogitStatus={'','Neogit'}, gitgraph={'','GitGraph'},
    gitstatus={'','GitStatus'}, lazygit={'','LazyGit'}, gitui={'','GitUI'},
    lazy={'󰒲','Lazy'}, mason={'󰏖','Mason'}, notify={'','Notify'}, noice={'','Noice'},
    ['noice-log']={'','Noice'}, ['noice-history']={'','Noice'},
    toggleterm={'','Terminal'}, Floaterm={'','Terminal'}, FTerm={'','FTerm'}, termwrapper={'','TermWrap'},
    Outline={'','Outline'}, aerial={'','Aerial'}, ['symbols-outline']={'','Symbols'}, OutlinePanel={'','Outline'},
    lspinfo={'','LSP Info'}, checkhealth={'','Health'}, OverseerList={'','Overseer'}, Overseer={'','Overseer'},
    Trouble={'','Trouble'}, ['trouble']={'','Trouble'},
    alpha={'','Alpha'}, dashboard={'','Dashboard'}, startify={'','Startify'}, ['start-screen']={'','Start'},
    helpview={'','Help'}, todo_comments={'','TODO'}, comment_box={'','CommentBox'},
    markdown_preview={'','Preview'}, glow={'','Glow'}, peek={'','Peek'},
    httpResult={'','HTTP'}, ['rest-nvim']={'','REST'},
    neoformat={'','Neoformat'}, undotree={'','Undotree'}, tagbar={'','Tagbar'}, vista={'','Vista'},
    octo={'','Octo'}, harpoon={'󰛢','Harpoon'}, which_key={'','WhichKey'},
    snacks_dashboard={'','Dashboard'}, snacks_notifier={'','Notify'}, snacks_indent={'','Indent'},
    zen_mode={'','Zen'}, goyo={'','Goyo'}, twilight={'','Twilight'},
    SagaOutline={'','Lspsaga'}, saga_codeaction={'','Code Action'}, SagaRename={'','Rename'},
    ['lspsaga-code-action']={'','Code Action'}, ['lspsaga-outline']={'','Lspsaga'},
    conform_info={'','Conform'}, ['null-ls-info']={'','Null-LS'}, ['diagnostic-navigator']={'','Diagnostics'},
    dapui_scopes={'','DAP Scopes'}, dapui_breakpoints={'','DAP Breakpoints'},
    dapui_stacks={'','DAP Stacks'}, dapui_watches={'','DAP Watches'},
    ['dap-repl']={'','DAP REPL'}, dapui_console={'','DAP Console'}, dapui_hover={'','DAP Hover'},
    dap_floating={'','DAP Float'},
    ['neotest-summary']={'','Neotest'}, ['neotest-output']={'','Neotest'}, ['neotest-output-panel']={'','Neotest'},
    copilot={'','Copilot'}, ['copilot-chat']={'','Copilot Chat'},
    ['vim-plug']={'','vim-plug'},
  }

  local function build_special_list()
    local base = {
      'qf','help','man','lspinfo','checkhealth','undotree','tagbar','vista','which_key',
      'TelescopePrompt','TelescopeResults','fzf','fzf%-lua','fzf%-checkmarks','grug%-far','Spectre','spectre_panel','spectre%-replace',
      'NvimTree','neo%-tree','Neotree','neo%-tree%-popup','oil','dirbuf','lir','fern','chadtree','defx','ranger','vifm','minifiles','mf','vaffle','netrw','explore','dirvish','yazi',
      '^git.*','fugitive','fugitiveblame','DiffviewFiles','DiffviewFileHistory','gitcommit','gitrebase','gitconfig',
      'NeogitCommitMessage','NeogitStatus','gitgraph','gitstatus','lazygit','gitui',
      'lazy','mason','notify','noice','noice%-log','noice%-history','toggleterm','Floaterm','FTerm','termwrapper',
      'Outline','aerial','symbols%-outline','OutlinePanel','OverseerList','Overseer','Trouble','trouble',
      'alpha','dashboard','startify','start%-screen','helpview','todo%-comments','comment%-box',
      'markdown_preview','glow','peek',
      'httpResult','rest%-nvim','neoformat','snacks_dashboard','snacks_notifier','snacks_indent','zen_mode','goyo','twilight',
      'SagaOutline','saga_codeaction','SagaRename','lspsaga%-code%-action','lspsaga%-outline','conform_info','null%-ls%-info','diagnostic%-navigator',
      'dapui_scopes','dapui_breakpoints','dapui_stacks','dapui_watches','dap%-repl','dapui_console','dapui_hover','dap_floating',
      'neotest%-summary','neotest%-output','neotest%-output%-panel',
      'copilot','copilot%-chat','vim%-plug',
      'terminal',
    }
    local extra = vim.g.heirline_special_ft_extra
    if type(extra) == 'table' then for _, pat in ipairs(extra) do table.insert(base, pat) end end
    return base
  end
  local SPECIAL_FT = build_special_list()

  local function ft_label_and_icon()
    local buf = target_buf()
    local bt = buf_option(buf, 'buftype', vim.bo.buftype)
    local ft = buf_option(buf, 'filetype', vim.bo.filetype)
    if bt ~= '' then
      local m=FT_ICON[bt]; if m then return m[2], (USE_ICONS and m[1] or '['..m[2]..']') end
      return bt, '['..bt..']'
    end
    if ft ~= '' then
      if ft=='Neotree' then ft='neo-tree' end
      local m=FT_ICON[ft]; if m then return m[2], (USE_ICONS and m[1] or '['..m[2]..']') end
      return ft, '['..ft..']'
    end
    return 'Special','[special]'
  end

  -- ── Smart truncation helpers ───────────────────────────────────────────────
  local function truncate_filename(name, max)
    if #name <= max then return name end
    local base, ext = name:match('^(.*)%.([^.]+)$')
    if not base then return name:sub(1, math.max(3, max-1)) .. '…' end
    local keep = math.max(3, max - (#ext + 2))
    return base:sub(1, keep) .. '….' .. ext
  end
  local function adapt_fname(max_hint)
    local win = get_status_win()
    local target = (win and api.nvim_win_is_valid(win)) and win or 0
    local ok_w, width = pcall(api.nvim_win_get_width, target)
    if not ok_w then
      local fallback_ok, fallback = pcall(api.nvim_win_get_width, 0)
      width = (fallback_ok and fallback) or 0
    end
    local max = max_hint or math.max(10, math.floor((width or 0) * 0.25))
    if max <= 0 then max = max_hint or 10 end
    local name = buf_display_name(get_status_buf())
    if name == '' then return ' [No Name]' end
    return ' ' .. truncate_filename(name, max)
  end

  -- ── Left (file info) ──────────────────────────────────────────────────────
  local _icon_color_cache = {}
  local highlights = require('heirline.highlights')
  local CurrentDir = {
    init = function(self)
      local cwd = win_cwd(get_status_win())
      local display = fn.fnamemodify(cwd, ':~') or ''
      self._parts = {}
      local function push(text, hl)
        if not text or text == '' then return end
        self._parts[#self._parts + 1] = { text = text, hl = hl }
      end
      local function slash_part()
        return { fg = colors.blue, bg = colors.base_bg }
      end
      local default_hl = { fg = colors.dir_mid or colors.white, bg = colors.base_bg }
      local rest = display
      if rest:sub(1, 1) == '~' then
        push('~', { fg = colors.green, bg = colors.base_bg, bold = true })
        rest = rest:sub(2)
      elseif rest:sub(1, 1) == '/' then
        push('/', slash_part())
        rest = rest:sub(2)
      end
      local idx = 1
      while idx <= #rest do
        local slash_pos = rest:find('/', idx)
        if slash_pos then
          local segment = rest:sub(idx, slash_pos - 1)
          push(segment, default_hl)
          push('/', slash_part())
          idx = slash_pos + 1
        else
          local tail = rest:sub(idx)
          push(tail, default_hl)
          break
        end
      end
      if #rest == 0 and #self._parts == 0 then
        push(display, default_hl)
      end
    end,
    update = { 'DirChanged', 'BufEnter' },
    on_click = { callback = vim.schedule_wrap(function() dbg_push('click: cwd'); open_file_browser_cwd() end), name = 'heirline_cwd_open' },
    provider = function(self)
      local parts = self._parts or {}
      local chunks = {}
      for _, part in ipairs(parts) do
        local hl = part.hl or { fg = colors.white, bg = colors.base_bg }
        local start_hl, end_hl = highlights.eval_hl(hl)
        chunks[#chunks + 1] = start_hl .. (part.text or '') .. end_hl
      end
      return table.concat(chunks)
    end,
  }
  local function file_icon_for(buf)
    local name = buf_display_name(buf)
    if name == '' then return S.doc, colors.cyan end
    if not ok_devicons or not USE_ICONS then return S.doc, colors.cyan end
    if _icon_color_cache[name] then return devicons.get_icon(name) or S.doc, _icon_color_cache[name] end
    local icon, color = devicons.get_icon_color(name, nil, { default = false })
    if color then _icon_color_cache[name] = color end
    return icon or S.doc, color or colors.cyan
  end

  local FileIcon = {
    condition = function() return not is_empty() end,
    provider = prof('FileIcon', function()
      local icon = file_icon_for(get_status_buf())
      return icon
    end),
    hl = function()
      local _, color = file_icon_for(get_status_buf())
      return { fg = color, bg = colors.base_bg }
    end,
    update = { 'BufEnter', 'BufFilePost' },
  }
  local Readonly = {
    condition = function()
      local buf = target_buf()
      local readonly = buf_option(buf, 'readonly', vim.bo.readonly)
      local modifiable = buf_option(buf, 'modifiable', vim.bo.modifiable)
      return readonly or not modifiable
    end,
    provider = S.lock,
    hl = function() return { fg = colors.blue, bg = colors.base_bg } end,
    update = { 'OptionSet', 'BufEnter' },
  }
  local FileNameClickable = {
    provider = prof('FileName', function() return adapt_fname() end),
    hl = function() return { fg = colors.white, bg = colors.base_bg } end,
    update = { 'BufEnter', 'BufFilePost', 'WinResized' },
    on_click = { callback = vim.schedule_wrap(function()
      local path = buf_full_path(get_status_buf())
      if not path or path == '' then return end
      pcall(fn.setreg, '+', path); notify('Copied path: ' .. path); dbg_push('click: filename -> copied path')
    end), name = 'heirline_copy_abs_path' },
  }
  -- ── Small toggles ─────────────────────────────────────────────────────────
  local function panel_divider()
    return { provider = '' }
  end

  local function visual_selection_stats()
    local win = target_win()
    if not win or not api.nvim_win_is_valid(win) then return nil end
    local ok, info = pcall(api.nvim_win_call, win, function()
      local mode = vim.fn.mode(1)
      if type(mode) ~= 'string' or not mode:match('[vV\022]') then return nil end
      local vmode = vim.fn.visualmode() or mode
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      if not start_pos or not end_pos then return nil end
      local wc = vim.fn.wordcount() or {}
      return { mode = mode, vmode = vmode, start = start_pos, finish = end_pos, wc = wc }
    end)
    if not ok or not info then return nil end
    local srow, scol = info.start[2], info.start[3]
    local erow, ecol = info.finish[2], info.finish[3]
    if srow == 0 or erow == 0 then return nil end
    local rows = math.abs(erow - srow) + 1
    local cols = math.abs(ecol - scol) + 1
    if info.vmode == 'V' then
      return {
        label = 'VLine',
        detail = tostring(rows),
      }
    elseif info.vmode == '\022' then
      return {
        label = 'VBlock',
        detail = string.format('%dx%d', rows, cols),
      }
    else
      local chars = info.wc.visual_chars or 0
      return {
        label = 'Visual',
        detail = (chars > 0) and tostring(chars) or nil,
      }
    end
  end

  local ListToggle = {
    update = { 'OptionSet', 'BufWinEnter', 'WinEnter' },
    on_click = { callback = vim.schedule_wrap(function()
      vim.o.list = not vim.o.list
      dbg_push('toggle: list -> '..tostring(vim.o.list))
    end), name = 'heirline_toggle_list' },
    {
      condition = function()
        return win_option(target_win(), 'list', vim.wo.list) == true
      end,
      panel_divider(),
      {
        provider = function() return 'list·on ' end,
        hl = function() return { fg = colors.yellow, bg = colors.base_bg, italic = true } end,
      },
    },
  }
  local WrapToggle = {
    update = { 'OptionSet', 'BufWinEnter', 'WinEnter' },
    on_click = { callback = vim.schedule_wrap(function()
      vim.wo.wrap = not vim.wo.wrap
      dbg_push('toggle: wrap -> '..tostring(vim.wo.wrap))
    end), name = 'heirline_toggle_wrap' },
    {
      condition = function()
        return win_option(target_win(), 'wrap', vim.wo.wrap) == true
      end,
      panel_divider(),
      {
        provider = function() return 'wrap·on ' end,
        hl = function() return { fg = colors.yellow, bg = colors.base_bg, italic = true } end,
      },
    },
  }

  -- ── Format panel (indent mode, ts, sw) ────────────────────────────────────
  local FormatPanel = {
    init = function(self)
      local buf = target_buf()
      self.expandtab = buf_option(buf, 'expandtab', vim.bo.expandtab)
      self.tabstop = buf_option(buf, 'tabstop', vim.bo.tabstop)
    end,
    update = { 'OptionSet', 'BufWinEnter', 'WinEnter' },
    panel_divider(),
    {
      {
        provider = function(self) return self.expandtab and '␠' or '⇥' end,
        hl = function() return { fg = colors.cyan, bg = colors.base_bg, italic = true } end,
      },
      {
        provider = function(self)
          return string.format('×%d ', self.tabstop)
        end,
        hl = function() return { fg = colors.white, bg = colors.base_bg, italic = true } end,
      },
      on_click = { callback = vim.schedule_wrap(function()
        vim.bo.expandtab = not vim.bo.expandtab
        dbg_push('toggle: expandtab -> '..tostring(vim.bo.expandtab))
      end), name = 'heirline_fmt_toggle_et' },
    },
  }

  local VisualSelection = {
    init = function(self)
      self._stats = visual_selection_stats()
    end,
    condition = function(self)
      self._stats = visual_selection_stats()
      return self._stats ~= nil
    end,
    update = { 'ModeChanged', 'CursorMoved', 'CursorMovedI', 'WinEnter', 'WinLeave', 'VisualEnter', 'VisualLeave', 'BufEnter' },
    provider = function(self)
      local stats = self._stats
      if not stats then return '' end
      local label = stats.label or 'Visual'
      local detail = stats.detail
      local text = detail and (label .. ' ' .. detail) or label
      local start_hl, end_hl = highlights.eval_hl({ fg = colors.yellow, bg = colors.base_bg, italic = true, bold = true })
      return start_hl .. text .. end_hl .. ' '
    end,
  }

  -- ── Git helpers ───────────────────────────────────────────────────────────
  local function gitsigns_head(bufnr)
    if not bufnr then return nil end
    local ok, head = pcall(api.nvim_buf_get_var, bufnr, 'gitsigns_head')
    if not ok or type(head) ~= 'string' or head == '' then return nil end
    return head
  end
  local function gitsigns_counts(bufnr)
    if not bufnr then return nil end
    local ok, dict = pcall(api.nvim_buf_get_var, bufnr, 'gitsigns_status_dict')
    if not ok or type(dict) ~= 'table' then return nil end
    return dict
  end

  -- ── Right-side helpers ────────────────────────────────────────────────────
  local function human_size()
    local path = buf_full_path(get_status_buf())
    if not path or path == '' then return '' end
    local size = fn.getfsize(path); if size <= 0 then return '' end
    local i, suffix = 1, { 'B','K','M','G','T','P' }
    while size >= 1024 and i < #suffix do size = size/1024; i=i+1 end
    if i == 1 then return string.format('%d%s', size, suffix[i]) end
    return string.format((i<=3) and '%.1f%s' or '%.2f%s', size, suffix[i])
  end
  local function os_icon()
    local buf = target_buf()
    local fmt = buf_option(buf, 'fileformat', vim.bo.fileformat)
    if not USE_ICONS then
      return ({ unix='unix ', mac='mac ', dos='dos ' })[fmt] or 'unix '
    end
    return ({ unix=S.linux, mac=S.mac, dos=S.win })[fmt] .. ' '
  end
  local function enc_icon()
    local buf = target_buf()
    local enc = buf_option(buf, 'fileencoding', vim.bo.fileencoding)
    if not enc or enc == '' then enc = vim.o.encoding or 'utf-8' end
    enc = enc:lower()
    return (enc == 'utf-8') and (S.utf8 .. ' ') or (S.latin .. ' ')
  end

  -- Search debounce
  local SEARCH_DEBOUNCE_MS = 90
  local last_sc = { t = 0, out = '', pat = '', cur = 0, tot = 0 }
  local function now_ms() return math.floor(vim.loop.hrtime() / 1e6) end

  -- ── Mode pill ─────────────────────────────────────────────────────────────
  local function mode_info()
    local m = vim.fn.mode(1)
    if m:match('^i') then return 'INSERT', colors.mode_ins_bg, 'I'
    elseif m:match('^v') or m == 'V' or m == '\22' then return 'VISUAL', colors.mode_vis_bg, 'V'
    elseif m:match('^R') then return 'REPLACE', colors.mode_rep_bg, 'R'
    else return 'NORMAL', colors.base_bg, 'N' end
  end
  local ModePill = {
    init = function(self)
      self.label, self.bg, self.short = mode_info()
    end,
    provider = function(self)
      if is_tiny() then return ' ' .. self.short .. ' ' end
      return ' ' .. self.label .. ' '
    end,
    hl = function(self) return { fg = colors.white, bg = self.bg } end,
    update = { 'ModeChanged', 'WinEnter' },
  }

  -- ── Macro timer state ─────────────────────────────────────────────────────
  local macro_start = nil
  api.nvim_create_autocmd('RecordingEnter', {
    callback = function() macro_start = vim.loop.hrtime() end,
  })
  api.nvim_create_autocmd('RecordingLeave', {
    callback = function() macro_start = nil end,
  })
  local function macro_elapsed()
    if not macro_start then return '00:00' end
    local s = (vim.loop.hrtime() - macro_start) / 1e9
    local mm = math.floor(s / 60)
    local ss = math.floor(s % 60)
    return string.format('%02d:%02d', mm, ss)
  end

  -- ── Components ────────────────────────────────────────────────────────────
  local components = {
    macro = {
      condition = function() return fn.reg_recording() ~= '' end,
      provider = prof('macro', function()
        return ' ' .. S.rec .. ' @' .. fn.reg_recording() .. ' ' .. macro_elapsed() .. ' '
      end),
      hl = function() return { fg = colors.red, bg = colors.base_bg } end,
      update = { 'RecordingEnter', 'RecordingLeave', 'CursorHold', 'CursorHoldI' },
    },

    diag = {
      condition = function(self)
        if is_narrow() then return false end
        local buf = target_buf()
        if not buf then return false end
        local diags = vim.diagnostic.get(buf)
        if #diags == 0 then return false end
        self._status_buf = buf
        return true
      end,
      init = function(self)
        local buf = self._status_buf or target_buf()
        self.errors = #vim.diagnostic.get(buf or 0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(buf or 0, { severity = vim.diagnostic.severity.WARN })
      end,
      update = { 'DiagnosticChanged', 'BufEnter', 'BufNew', 'WinEnter', 'WinResized' },
      {
        provider = prof('diag.errors', function(self) return (self.errors or 0) > 0 and (S.err .. self.errors .. ' ') or '' end),
        hl = function() return { fg = colors.red, bg = colors.base_bg } end,
      },
      {
        provider = prof('diag.warns', function(self) return (self.warnings or 0) > 0 and (S.warn .. self.warnings .. ' ') or '' end),
        hl = function() return { fg = colors.yellow, bg = colors.base_bg } end,
      },
      on_click = { callback = vim.schedule_wrap(function(_,_,_,button)
        dbg_push('click: diagnostics ('..tostring(button)..')')
        if button == 'l' then open_diagnostics_list()
        elseif button == 'm' then pcall(vim.diagnostic.goto_next)
        elseif button == 'r' then pcall(vim.diagnostic.goto_prev)
        end
      end), name = 'heirline_diagnostics_click' },
    },

    lsp = {
      condition = function()
        local buf = target_buf()
        if not buf then return false end
        local clients = {}
        if vim.lsp and vim.lsp.get_clients then
          clients = vim.lsp.get_clients({ bufnr = buf })
        elseif vim.lsp and vim.lsp.buf_get_clients then
          local map = vim.lsp.buf_get_clients(buf)
          for _, client in pairs(map or {}) do table.insert(clients, client) end
        end
        return #clients > 0
      end,
      provider = S.gear,
      hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
      on_click = { callback = vim.schedule_wrap(function() dbg_push('click: lsp'); vim.cmd('LspInfo') end), name = 'heirline_lsp_info' },
      update = { 'LspAttach', 'LspDetach', 'BufEnter', 'WinEnter' },
    },

    lsp_progress = {
      condition = function()
        local buf = target_buf()
        if not buf then return false end
        if vim.lsp and vim.lsp.get_clients then
          return #vim.lsp.get_clients({ bufnr = buf }) > 0
        end
        if vim.lsp and vim.lsp.buf_get_clients then
          local map = vim.lsp.buf_get_clients(buf)
          return map and (vim.tbl_count(map) > 0)
        end
        return false
      end,
      init = function(self)
        self.frames = { '⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏' }
        self.idx = (self.idx or 0) + 1
        if self.idx > #self.frames then self.idx = 1 end
        local msgs = {}
        if vim.lsp and vim.lsp.util and vim.lsp.util.get_progress_messages then
          for _, m in ipairs(vim.lsp.util.get_progress_messages()) do
            local title = m.title or m.message or ''
            local pct = m.percentage and (m.percentage .. '%%') or ''
            if title ~= '' then table.insert(msgs, (pct ~= '' and (title .. ' ' .. pct) or title)) end
          end
        end
        self.text = table.concat(msgs, ' | ')
      end,
      provider = function(self)
        if self.text == nil or self.text == '' then return '' end
        return string.format(' %s %s ', self.frames[self.idx], self.text)
      end,
      hl = function() return { fg = colors.blue_light, bg = colors.base_bg } end,
      update = { 'LspAttach', 'LspDetach', 'CursorHold', 'CursorHoldI', 'BufEnter', 'WinEnter' },
    },

    git = {
      condition = function(self)
        if is_narrow() then return false end
        local buf = target_buf()
        if not buf then return false end
        local head = gitsigns_head(buf)
        if not head then return false end
        self._status_buf = buf
        self.head = head
        return true
      end,
      update = { 'BufEnter', 'BufWritePost', 'User', 'WinEnter', 'WinResized' },
      on_click = { callback = vim.schedule_wrap(function() dbg_push('click: git'); open_git_ui() end), name = 'heirline_git_ui' },
      {
        provider = function() return S.branch end,
        hl = function() return { fg = colors.blue, bg = colors.base_bg } end,
      },
      {
        provider = prof('git.head', function(self)
          return (self.head or '') .. ' '
        end),
        hl = function() return { fg = colors.white, bg = colors.base_bg } end,
      },
    },

    gitdiff = {
      condition = function(self)
        if is_narrow() then return false end
        local buf = target_buf()
        if not buf then return false end
        local dict = gitsigns_counts(buf)
        if not dict then return false end
        self._status_buf = buf
        self.added = dict.added or 0
        self.changed = dict.changed or 0
        self.removed = dict.removed or 0
        return true
      end,
      update = { 'BufEnter', 'BufWritePost', 'User', 'WinEnter', 'WinResized' },
      {
        condition = function(self) return (self.added or 0) > 0 end,
        { provider = function() return S.plus end, hl = 'HeirlineDiffAddIcon' },
        {
          provider = function(self) return tostring(self.added) end,
          hl = function() return { fg = colors.white, bg = colors.base_bg, italic = true } end,
        },
      },
      {
        condition = function(self) return (self.changed or 0) > 0 end,
        { provider = function() return S.tilde end, hl = 'HeirlineDiffChangeIcon' },
        {
          provider = function(self) return tostring(self.changed) end,
          hl = function() return { fg = colors.white, bg = colors.base_bg, italic = true } end,
        },
      },
      {
        condition = function(self) return (self.removed or 0) > 0 end,
        { provider = function() return S.minus end, hl = 'HeirlineDiffDelIcon' },
        {
          provider = function(self) return tostring(self.removed) end,
          hl = function() return { fg = colors.white, bg = colors.base_bg, italic = true } end,
        },
      },
      on_click = { callback = vim.schedule_wrap(function(_,_,_,button)
        dbg_push('click: gitdiff ('..tostring(button)..')')
        local ok, gs = pcall(require,'gitsigns'); if not ok then return end
        if button == 'l' then gs.preview_hunk()
        elseif button == 'm' then gs.next_hunk()
        elseif button == 'r' then gs.prev_hunk()
        end
      end), name = 'heirline_gitdiff_click' },
    },

    encoding = {
      provider = prof('encoding', function() return ' ' .. os_icon() .. enc_icon() end),
      hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
      update = { 'OptionSet', 'BufEnter' },
    },

    size = {
      condition = function() return not is_empty() and not is_narrow() end,
      init = function(self)
        self._size = human_size()
      end,
      update = { 'BufEnter', 'BufWritePost', 'WinResized' },
      on_click = {
        callback = vim.schedule_wrap(function()
          dbg_push('click: size -> buffer fuzzy find')
          if has_mod('telescope.builtin') then require('telescope.builtin').current_buffer_fuzzy_find() end
        end),
        name = 'heirline_size_click',
      },
      {
        condition = function(self) return self._size ~= '' end,
        provider = ' ',
      },
      {
        condition = function(self) return self._size ~= '' end,
        provider = function() return '' end,
        hl = 'HeirlineSizeIcon',
      },
      {
        condition = function(self) return self._size ~= '' end,
        provider = function(self) return self._size .. ' ' end,
        hl = function() return { fg = colors.white, bg = colors.base_bg, italic = true } end,
      },
      {
        condition = function(self) return self._size ~= '' end,
        provider = ' ',
        hl = function() return { fg = colors.white, bg = colors.base_bg } end,
      },
    },

    search = {
      condition = function() return vim.v.hlsearch == 1 end,
      provider = prof('search', function()
        local t = now_ms()
        if t - last_sc.t < SEARCH_DEBOUNCE_MS then
          return last_sc.out
        end
        local ok_sc, s = pcall(fn.searchcount, { recompute = 1, maxcount = 1000 })
        local pattern = fn.getreg('/')
        if not ok_sc or not pattern or pattern == '' then
          last_sc.t, last_sc.out = t, ''
          return ''
        end
        if #pattern > 15 then pattern = pattern:sub(1, 12) .. '...' end
        local cur = (s and s.current) or 0
        local tot = (s and s.total) or 0
        local out = (tot == 0) and '' or string.format('%s%s %d/%d ', S.search, pattern, cur, tot)
        last_sc.t, last_sc.out, last_sc.pat, last_sc.cur, last_sc.tot = t, out, pattern, cur, tot
        return out
      end),
      hl = function() return { fg = colors.yellow, bg = colors.base_bg } end,
      update = { 'CmdlineLeave', 'CursorMoved', 'CursorMovedI' },
      on_click = { callback = vim.schedule_wrap(function() dbg_push('click: search -> nohlsearch'); pcall(vim.cmd,'nohlsearch') end), name = 'heirline_search_clear' },
    },

    position = {
      init = function(self)
        local win = target_win()
        self._pos = win_call(win, function()
          local lnum = fn.line('.')
          local col = fn.virtcol('.')
          local show_col = col ~= 1
          local full = string.format('%04d', lnum)
          local lead = full:match('^0+') or ''
          local rest = full:sub(#lead + 1)
          if rest == '' then rest = '0' end
          self._pos_lead = lead
          self._pos_rest = rest
          self._pos_col = show_col and col or nil
          if show_col then
            return full .. ':' .. col
          end
          return full
        end, '0000')
      end,
      update = { 'CursorMoved', 'CursorMovedI', 'WinResized' },
      {
        condition = function(self) return self._pos ~= nil and self._pos ~= '' end,
        provider = ' ',
      },
      {
        condition = function(self) return self._pos ~= nil and self._pos ~= '' end,
        provider = function() return '🅻🅽' end,
        hl = 'HeirlinePositionIcon',
      },
      {
        condition = function(self) return self._pos ~= nil and self._pos ~= '' end,
        provider = function(self)
          local lead = self._pos_lead or ''
          local rest = self._pos_rest or ''
          local col = self._pos_col
          local pieces = {}
          if lead ~= '' then
            -- Draw padded zeros with kitty color243 (via colors.line_zero).
            local start, finish = highlights.eval_hl({ fg = colors.line_zero or colors.white_dim, bg = colors.base_bg, italic = true })
            pieces[#pieces + 1] = start .. lead .. finish
          end
          if rest ~= '' then
            local start, finish = highlights.eval_hl({ fg = colors.white, bg = colors.base_bg, italic = true })
            pieces[#pieces + 1] = start .. rest .. finish
          end
          if col then
            local start_sep, end_sep = highlights.eval_hl({ fg = colors.blue, bg = colors.base_bg, italic = true })
            local start_col, end_col = highlights.eval_hl({ fg = colors.white, bg = colors.base_bg, italic = true })
            pieces[#pieces + 1] = start_sep .. ':' .. end_sep
            pieces[#pieces + 1] = start_col .. tostring(col) .. end_col
          end
          if #pieces == 0 then return '' end
          return table.concat(pieces) .. ' '
        end,
      },
    },

    env = {
      condition = function()
        if not SHOW_ENV then return false end
        local lbl = env_label()
        return lbl ~= nil and lbl ~= ''
      end,
      init = function(self)
        self._env_label = env_label() or ''
      end,
      update = { 'VimResized' },
      panel_divider(),
      {
        provider = function(self)
          return 'env·' .. self._env_label .. ' '
        end,
        hl = function() return { fg = colors.blue_light, bg = colors.base_bg, italic = true } end,
      },
    },

    toggles = { ListToggle, WrapToggle },
    format_panel = FormatPanel,
    visual_selection = VisualSelection,
  }

  local ModifiedFlag = {
    condition = function()
      local buf = target_buf()
      return buf_option(buf, 'modified', vim.bo.modified)
    end,
    provider = S.modified,
    hl = function() return { fg = colors.blue, bg = colors.base_bg } end,
    update = { 'BufWritePost', 'TextChanged', 'TextChangedI', 'BufModifiedSet' },
  }

  local EmptyBadge = {
    condition = is_empty,
    -- Default statusline prints "No Name" for unnamed buffers (:h statusline).
    provider = function()
      local par_start, par_end = highlights.eval_hl({ fg = colors.blue, bg = colors.base_bg, bold = true })
      local text_start, text_end = highlights.eval_hl({ fg = colors.white, bg = colors.base_bg, bold = true })
      return table.concat({
        par_start, '(', par_end,
        text_start, 'No Name', text_end,
        par_start, ')', par_end,
        ' ',
      })
    end,
  }

  local CenterFilePath = {
    condition = function() return not is_empty() end,
    init = function(self)
      local buf = get_status_buf()
      local path = buf_full_path(buf)
      if not path or path == '' then self._parts = nil; return end
      local display = fn.fnamemodify(path, ':~')
      local parts = {}
      local function push(text, hl)
        if not text or text == '' then return end
        parts[#parts + 1] = { text = text, hl = hl }
      end
      local slash_hl = { fg = colors.blue, bg = colors.base_bg, italic = true }
      local dir_hl = { fg = colors.dir_mid or colors.white, bg = colors.base_bg, italic = true }
      local file_hl = { fg = colors.white, bg = colors.base_bg, bold = true }

      local dir_part, file_part = display:match('^(.*)/([^/]+)$')
      if not file_part then
        file_part = display
        dir_part = nil
      end

      local function emit_dirs(rest)
        if not rest or rest == '' then return end
        local cursor = rest
        if cursor:sub(1, 1) == '~' then
          push('~', { fg = colors.green, bg = colors.base_bg, bold = true })
          cursor = cursor:sub(2)
        elseif cursor:sub(1, 1) == '/' then
          push('/', slash_hl)
          cursor = cursor:sub(2)
        end
        local idx = 1
        while idx <= #cursor do
          local slash_pos = cursor:find('/', idx)
          if slash_pos then
            local segment = cursor:sub(idx, slash_pos - 1)
            push(segment, dir_hl)
            push('/', slash_hl)
            idx = slash_pos + 1
          else
            local tail = cursor:sub(idx)
            push(tail, dir_hl)
            break
          end
        end
      end

      emit_dirs(dir_part)
      if dir_part and dir_part ~= '' then push('/', slash_hl) end
      if display:sub(1, 1) == '/' and not dir_part then push('/', slash_hl) end
      local icon, icon_color = file_icon_for(buf)
      push(icon .. ' ', { fg = icon_color, bg = colors.base_bg })
      push(file_part, file_hl)

      self._parts = parts
    end,
    update = { 'BufEnter', 'BufFilePost', 'DirChanged', 'WinResized' },
    provider = function(self)
      local parts = self._parts
      if not parts or #parts == 0 then return '' end
      local chunks = { ' ' }
      for _, part in ipairs(parts) do
        local hl = part.hl or { fg = colors.white, bg = colors.base_bg }
        local start_hl, end_hl = highlights.eval_hl(hl)
        chunks[#chunks + 1] = start_hl .. (part.text or '') .. end_hl
      end
      chunks[#chunks + 1] = ' '
      return table.concat(chunks)
    end,
  }

  local LeftComponents = {
    condition = function() return not is_empty() end,
    {
      provider = function()
        local cwd = win_cwd(get_status_win())
        local home = fn.expand('~')
        if cwd == home then
          return (USE_ICONS and ' ' or '~ ')
        end
        return S.folder .. ' '
      end,
      hl = function()
        local cwd = win_cwd(get_status_win())
        local home = fn.expand('~')
        local is_home = (cwd == home)
        return { fg = (is_home and colors.green or colors.blue), bg = colors.base_bg }
      end,
      update = { 'DirChanged' },
    },
    CurrentDir,
    { provider = S.sep, hl = function() return { fg = colors.blue, bg = colors.base_bg } end },
    FileIcon,
    FileNameClickable,
    Readonly,
    ModifiedFlag,
  }

  -- ── Special buffer statusline ─────────────────────────────────────────────
  local SpecialBuffer = {
    condition = function()
      return safe_buffer_matches({
        buftype = { 'help','quickfix','terminal','prompt','nofile' },
        filetype = SPECIAL_FT,
      })
    end,
    hl = function() return { fg = colors.white, bg = colors.base_bg } end,

    {
      provider = prof('special.label', function()
        local label, icon = ft_label_and_icon()
        return string.format(' %s %s', icon or '[*]', label or 'Special')
      end),
      hl = function() return { fg = colors.cyan, bg = colors.base_bg } end,
    },
    { provider = '%=' },
    {
      condition = function() return not is_empty() end,
      provider = prof('special.filename', function() return ' ' .. adapt_fname(30) .. ' ' end),
      hl = function() return { fg = colors.white, bg = colors.base_bg } end,
      on_click = { callback = vim.schedule_wrap(function()
        local path = buf_full_path(get_status_buf())
        if not path or path == '' then return end
        pcall(fn.setreg, '+', path); notify('Copied path: ' .. path); dbg_push('click: special filename -> copied path')
      end), name = 'heirline_special_copy_path' },
    },
    {
      provider = ' ' .. S.close .. ' ',
      hl = function() return { fg = colors.red, bg = colors.base_bg } end,
      on_click = { callback = vim.schedule_wrap(function() dbg_push('click: close buffer'); vim.cmd('bd!') end), name = 'heirline_close_buf' },
    },
  }

  -- ── Default statusline ────────────────────────────────────────────────────
  local RightComponents = {
    components.macro,
    components.diag,
    components.lsp,
    components.lsp_progress,
    components.encoding,
    components.git,
    components.gitdiff,
    components.size,
    components.env,
    components.format_panel,
    components.toggles,
    components.position,
  }

  -- Center path still experimental: keep disabled until layout finalized.
  local ENABLE_CENTER_PATH = false

  local DefaultStatusline
  if ENABLE_CENTER_PATH then
    DefaultStatusline = {
      utils.surround({ '', '' }, colors.base_bg, {
        VisualSelection,
        EmptyBadge,
        LeftComponents,
        components.search,
      }),
      align,
      CenterFilePath,
      align,
      RightComponents,
    }
  else
    DefaultStatusline = {
      utils.surround({ '', '' }, colors.base_bg, {
        EmptyBadge,
        LeftComponents,
        components.search,
      }),
      align,
      RightComponents,
    }
  end

  -- ── Ultra-compact statusline (tiny windows) ───────────────────────────────
  local TinyStatusline = {
    condition = is_tiny,
    utils.surround({ '', '' }, colors.base_bg, {
      ModePill,
      FileIcon,
      {
        provider = function() return adapt_fname(math.max(8, math.floor(win_w() * 0.35))) end,
        hl = function() return { fg = colors.white, bg = colors.base_bg } end,
        update = { 'BufEnter', 'BufFilePost', 'WinResized' },
      },
      align,
      components.position,
    }),
  }

  return {
    statusline = { fallthrough = false, TinyStatusline, SpecialBuffer, DefaultStatusline },
    SPECIAL_FT = SPECIAL_FT,
  }
end
