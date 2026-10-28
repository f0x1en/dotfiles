vim.opt.termguicolors = true
vim.g.colors_name = "campbell"

local c = {
    bg = "#0C0C0C",
    fg = "#CCCCCC",
    black = "#0C0C0C",

    -- Muted Campbell palette
    red = "#B06C75",
    green = "#819777",
    yellow = "#B8A477",
    blue = "#7892B2",
    purple = "#A08BAF",
    cyan = "#7FA6A6",
    white = "#CCCCCC",

    -- Softer foreground colors
    bright_black = "#777777",
    bright_red = "#C08086",
    bright_green = "#91A987",
    bright_yellow = "#C7B58D",
    bright_blue = "#8AA2C0",
    bright_purple = "#AE9ABB",
    bright_cyan = "#91B4B2",
    bright_white = "#E0E0E0",

    surface = "#1C1C1C",
    selection = "#353535",
    border = "#404040",
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
    Comment = { fg = "#777777", italic = true },
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
    Operator = { fg = "#AAAAAA" },
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
    Delimiter = { fg = "#A0A0A0" },
    Error = { fg = "#D0A0A0", underline = true },
    Todo = { fg = c.yellow, bold = true },

    -- Popup menu
    Pmenu = { fg = c.fg, bg = c.surface },
    PmenuSel = { fg = c.fg, bg = c.selection, bold = true },
    PmenuSbar = { bg = c.surface },
    PmenuThumb = { bg = "#666666" },

    -- Status line and splits
    StatusLine = { fg = c.fg, bg = "#242424" },
    StatusLineNC = { fg = "#888888", bg = "#171717" },
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
    ["@punctuation.bracket"] = { fg = "#AAAAAA" },
    ["@punctuation.delimiter"] = groups.Delimiter,
    ["@tag"] = { fg = c.red },
    ["@tag.attribute"] = { fg = c.blue },
}

for group, opts in pairs(treesitter) do
    vim.api.nvim_set_hl(0, group, opts)
end
