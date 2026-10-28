local digits = {
  ["۰"]="0", ["۱"]="1", ["۲"]="2", ["۳"]="3", ["۴"]="4",
  ["۵"]="5", ["۶"]="6", ["۷"]="7", ["۸"]="8", ["۹"]="9",
  ["٠"]="0", ["١"]="1", ["٢"]="2", ["٣"]="3", ["٤"]="4",
  ["٥"]="5", ["٦"]="6", ["٧"]="7", ["٨"]="8", ["٩"]="9",
}

function Str(elem)
  local text = elem.text

  for original, replacement in pairs(digits) do
    text = text:gsub(original, replacement)
  end

  if text:match("^[A-Za-z][A-Za-z0-9._+%-]*%d[A-Za-z0-9._+%-]*$") then
    return pandoc.RawInline("latex", "\\lr{" .. text .. "}")
  end

  local result = pandoc.List()
  local pos = 1

  while pos <= #text do
    local first, last = text:find("%d+", pos)

    if not first then
      result:insert(pandoc.Str(text:sub(pos)))
      break
    end

    if first > pos then
      result:insert(pandoc.Str(text:sub(pos, first - 1)))
    end

    result:insert(pandoc.RawInline("latex", "\\lr{" .. text:sub(first, last) .. "}"))
    pos = last + 1
  end

  if #result == 0 then
    return pandoc.Str(text)
  end

  return result
end
