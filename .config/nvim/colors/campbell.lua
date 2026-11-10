vim.opt.termguicolors = true
vim.g.colors_name = "campbell"

local c = {
    bg = "#0C0C0C",
    fg = "#B8B8B8",
    black = "#0C0C0C",

    -- Neutral grays + three accents (red / green / amber). Syntax uses only these:
    --   red = keywords, green = strings, amber = functions, strong = types/numbers.
    red = "#CC5F5A",
    green = "#7BAA62",
    yellow = "#D1A34D",
    blue = "#D4D4D4",
    purple = "#CC5F5A",
    cyan = "#D4D4D4",
    white = "#B8B8B8",

    bright_black = "#6B6B6B",
    bright_red = "#CC5F5A",
    bright_green = "#7BAA62",
    bright_yellow = "#D1A34D",
    bright_blue = "#D4D4D4",
    bright_purple = "#CC5F5A",
    bright_cyan = "#D4D4D4",
    bright_white = "#D4D4D4",

    surface = "#1C1C1C",
    selection = "#2E2E2E",
    border = "#383838",
}

local groups = {
    -- Editor
    Normal = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.surface },
    EndOfBuffer = { fg = c.surface },
    CursorLine = { bg = "#181818" },
    CursorLineNr = { fg = c.yellow, bold = true },
    LineNr = { fg = c.bright_black },
    SignColumn = { fg = c.bright_black, bg = c.bg },
    ColorColumn = { bg = c.surface },
    Visual = { bg = c.selection },
    Search = { fg = c.bg, bg = c.yellow },
    IncSearch = { fg = c.bg, bg = c.cyan },
    MatchParen = { fg = c.yellow, bold = true, underline = true },

    -- Syntax
    Comment = { fg = "#6B6B6B", italic = true },
    Constant = { fg = c.cyan },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.cyan },
    Boolean = { fg = c.purple },
    Float = { fg = c.cyan },

    Identifier = { fg = c.blue },
    Function = { fg = c.yellow },
    Statement = { fg = c.red },
    Conditional = { fg = c.red },
    Repeat = { fg = c.red },
    Label = { fg = c.red },
    Operator = { fg = "#8A8A8A" },
    Keyword = { fg = c.purple },
    Exception = { fg = c.red },

    PreProc = { fg = c.purple },
    Include = { fg = c.purple },
    Define = { fg = c.purple },
    Macro = { fg = c.purple },

    Type = { fg = c.blue },
    StorageClass = { fg = c.red },
    Structure = { fg = c.blue },
    Typedef = { fg = c.blue },

    Special = { fg = c.cyan },
    SpecialChar = { fg = c.yellow },
    Delimiter = { fg = "#7E7E7E" },
    Error = { fg = "#A87070", underline = true },
    Todo = { fg = c.yellow, bold = true },

    -- Popup menu
    Pmenu = { fg = c.fg, bg = c.surface },
    PmenuSel = { fg = c.fg, bg = c.selection, bold = true },
    PmenuSbar = { bg = c.surface },
    PmenuThumb = { bg = "#666666" },

    -- Status line and splits
    StatusLine = { fg = c.fg, bg = "#242424" },
    StatusLineNC = { fg = "#707070", bg = "#171717" },

    -- Tab bar (mini.tabline): active tab bright and bold, others dim
    MiniTablineCurrent = { fg = "#D4D4D4", bg = "#333333", bold = true },
    MiniTablineVisible = { fg = "#6B6B6B", bg = "#161616" },
    MiniTablineHidden = { fg = "#6B6B6B", bg = "#161616" },
    MiniTablineModifiedCurrent = { fg = "#D4D4D4", bg = "#333333", bold = true },
    MiniTablineModifiedVisible = { fg = "#6B6B6B", bg = "#161616" },
    MiniTablineModifiedHidden = { fg = "#6B6B6B", bg = "#161616" },
    MiniTablineFill = { bg = "#161616" },
    WinSeparator = { fg = c.border },
    VertSplit = { fg = c.border },

    -- Diagnostics
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.cyan },
    DiagnosticOk = { fg = c.green },

    -- Diff
    DiffAdd = { fg = c.green, bg = "#172019" },
    DiffChange = { fg = c.yellow, bg = "#211F18" },
    DiffDelete = { fg = c.red, bg = "#241719" },
    DiffText = { fg = c.yellow, bg = "#302A1D" },
}

for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
end

-- Modern Tree-sitter highlighting
local treesitter = {
    ["@comment"] = groups.Comment,
    ["@string"] = groups.String,
    ["@string.delimiter"] = groups.Delimiter,
    ["@character"] = groups.Character,
    ["@number"] = groups.Number,
    ["@boolean"] = groups.Boolean,
    ["@function"] = groups.Function,
    ["@function.call"] = groups.Function,
    ["@method"] = groups.Function,
    ["@method.call"] = groups.Function,
    ["@keyword"] = groups.Keyword,
    ["@keyword.return"] = groups.Statement,
    ["@conditional"] = groups.Conditional,
    ["@repeat"] = groups.Repeat,
    ["@operator"] = groups.Operator,
    ["@type"] = groups.Type,
    ["@type.builtin"] = groups.Type,
    ["@constant"] = groups.Constant,
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.red },
    ["@property"] = { fg = c.blue },
    ["@punctuation.bracket"] = { fg = "#8A8A8A" },
    ["@punctuation.delimiter"] = groups.Delimiter,
    ["@tag"] = { fg = c.red },
    ["@tag.attribute"] = { fg = c.blue },
}

for group, opts in pairs(treesitter) do
    vim.api.nvim_set_hl(0, group, opts)
end
