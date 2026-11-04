local digits = {
  ["۰"]="0", ["۱"]="1", ["۲"]="2", ["۳"]="3", ["۴"]="4",
  ["۵"]="5", ["۶"]="6", ["۷"]="7", ["۸"]="8", ["۹"]="9",
  ["٠"]="0", ["١"]="1", ["٢"]="2", ["٣"]="3", ["٤"]="4",
  ["٥"]="5", ["٦"]="6", ["٧"]="7", ["٨"]="8", ["٩"]="9",
}

local function western_digits(s)
  for original, replacement in pairs(digits) do
    s = s:gsub(original, replacement)
  end
  return s
end

function Str(elem)
  elem.text = western_digits(elem.text)
  return elem
end

function Code(elem)
  elem.text = western_digits(elem.text)
  return elem
end

function Math(elem)
  elem.text = western_digits(elem.text)
  return elem
end

function RawInline(elem)
  elem.text = western_digits(elem.text)
  return elem
end

function RawBlock(elem)
  elem.text = western_digits(elem.text)
  return elem
end

local function char_class(cp)
  -- ASCII letters and digits.
  if (cp >= 48 and cp <= 57)
    or (cp >= 65 and cp <= 90)
    or (cp >= 97 and cp <= 122) then
    return "latin"
  end

  -- Parentheses are handled separately.
  if cp == 40 or cp == 41 then
    return "paren"
  end

  -- Quotes belong with adjacent Latin text.
  if cp == 34 or cp == 39
    or cp == 0x2018 or cp == 0x2019
    or cp == 0x201C or cp == 0x201D then
    return "quote"
  end

  -- Persian and Arabic characters, marks and punctuation.
  if (cp >= 0x0600 and cp <= 0x06FF)
    or (cp >= 0x0750 and cp <= 0x077F)
    or (cp >= 0x08A0 and cp <= 0x08FF)
    or (cp >= 0xFB50 and cp <= 0xFDFF)
    or (cp >= 0xFE70 and cp <= 0xFEFF)
    or cp == 0x200C
    or cp == 0x200D then
    return "rtl"
  end

  -- Other ASCII / Unicode punctuation.
  if cp <= 127 or (cp >= 0x2000 and cp <= 0x206F) then
    return "punct"
  end

  return "other"
end

local function make_units(inlines)
  local units = {}

  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      for _, cp in utf8.codes(inline.text) do
        local char = utf8.char(cp)

        units[#units + 1] = {
          inline = pandoc.Str(char),
          text = char,
          class = char_class(cp)
        }
      end
    elseif inline.t == "Space" or inline.t == "SoftBreak" then
      units[#units + 1] = {
        inline = inline,
        text = " ",
        class = "space"
      }
    else
      units[#units + 1] = {
        inline = inline,
        class = "other"
      }
    end
  end

  return units
end

local function matching_parenthesis(units, start)
  local depth = 0

  for i = start, #units do
    if units[i].text == "(" then
      depth = depth + 1
    elseif units[i].text == ")" then
      depth = depth - 1

      if depth == 0 then
        return i
      end
    end
  end

  return nil
end

local function has_latin_inside(units, first, last)
  for i = first, last do
    if units[i].class == "latin" then
      return true
    end
  end

  return false
end

local function is_latin_punctuation(units, i)
  if units[i].class == "quote" then
    return true
  end

  if units[i].class ~= "punct" then
    return false
  end

  -- Punctuation belongs to a Latin run only when it is
  -- between Latin characters, e.g. 3.14 or well-known.
  local left = i - 1
  while left >= 1 and units[left].class == "punct" do
    left = left - 1
  end

  local right = i + 1
  while right <= #units and units[right].class == "punct" do
    right = right + 1
  end

  return left >= 1
    and right <= #units
    and units[left].class == "latin"
    and units[right].class == "latin"
end

local function emit_parenthesized(result, units, first, last)
  result:insert(pandoc.RawInline("latex", "\\en{"))
  result:insert(units[first].inline)

  local i = first + 1

  while i < last do
    if units[i].class == "rtl" then
      result:insert(pandoc.RawInline("latex", "\\rl{"))

      while i < last do
        if units[i].class == "rtl" then
          result:insert(units[i].inline)
          i = i + 1
        elseif units[i].class == "space"
          and i + 1 < last
          and units[i + 1].class == "rtl" then
          result:insert(units[i].inline)
          i = i + 1
        else
          break
        end
      end

      result:insert(pandoc.RawInline("latex", "}"))
    else
      result:insert(units[i].inline)
      i = i + 1
    end
  end

  result:insert(units[last].inline)
  result:insert(pandoc.RawInline("latex", "}"))
end

function Quoted(elem)
  -- Only change quote marks when the quoted text contains Latin text.
  if not pandoc.utils.stringify(elem.content):find("[A-Za-z0-9]") then
    return elem
  end

  local opening, closing

  if elem.quotetype == "SingleQuote" then
    opening = "\\en{`}"
    closing = "\\en{'}"
  else
    opening = "\\en{``}"
    closing = "\\en{''}"
  end

  local result = {
    pandoc.RawInline("latex", opening)
  }

  for _, inline in ipairs(elem.content) do
    result[#result + 1] = inline
  end

  result[#result + 1] = pandoc.RawInline("latex", closing)

  return result
end

function Inlines(inlines)
  local units = make_units(inlines)
  local result = pandoc.List()
  local i = 1

  while i <= #units do
    -- Handle a complete parenthesized expression before
    -- ordinary Latin grouping can consume its parentheses.
    if units[i].text == "(" then
      local close = matching_parenthesis(units, i)

      if close and has_latin_inside(units, i + 1, close - 1) then
        emit_parenthesized(result, units, i, close)
        i = close + 1
      else
        result:insert(units[i].inline)
        i = i + 1
      end

    elseif units[i].class == "latin"
      or is_latin_punctuation(units, i) then

      result:insert(pandoc.RawInline("latex", "\\en{"))

      while i <= #units do
        if units[i].class == "latin"
          or is_latin_punctuation(units, i) then
          result:insert(units[i].inline)
          i = i + 1

        elseif units[i].class == "space"
          and i < #units
          and units[i + 1].class == "latin" then
          result:insert(units[i].inline)
          i = i + 1

        else
          break
        end
      end

      result:insert(pandoc.RawInline("latex", "}"))

    else
      result:insert(units[i].inline)
      i = i + 1
    end
  end

  return result
end

local function has_persian(elem)
  return pandoc.utils.stringify(elem):find("[\216-\219]") ~= nil
end

function Para(elem)
  if not has_persian(elem) then
    return {
      pandoc.RawBlock("latex", "\\begin{latin}"),
      elem,
      pandoc.RawBlock("latex", "\\end{latin}")
    }
  end

  return elem
end

function Plain(elem)
  if not has_persian(elem) then
    return {
      pandoc.RawBlock("latex", "\\begin{latin}"),
      elem,
      pandoc.RawBlock("latex", "\\end{latin}")
    }
  end

  return elem
end

function Header(elem)
  if not has_persian(elem) then
    table.insert(elem.content, 1,
      pandoc.RawInline("latex", "\\begin{latin}"))

    elem.content:insert(
      pandoc.RawInline("latex", "\\end{latin}"))
  end

  return elem
end

function CodeBlock(elem)
  elem.text = western_digits(elem.text)

  return pandoc.RawBlock(
    "latex",
    "\\begin{latin}\n\\begin{verbatim}\n" ..
    elem.text ..
    "\n\\end{verbatim}\n\\end{latin}"
  )
end
