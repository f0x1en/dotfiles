-- Replace Persian and Arabic-Indic digits with Western digits.
local digits = {
  ["۰"]="0", ["۱"]="1", ["۲"]="2", ["۳"]="3", ["۴"]="4",
  ["۵"]="5", ["۶"]="6", ["۷"]="7", ["۸"]="8", ["۹"]="9",
  ["٠"]="0", ["١"]="1", ["٢"]="2", ["٣"]="3", ["٤"]="4",
  ["٥"]="5", ["٦"]="6", ["٧"]="7", ["٨"]="8", ["٩"]="9",
}

local function western_digits(elem)
  for original, replacement in pairs(digits) do
    elem.text = elem.text:gsub(original, replacement)
  end
  return elem
end

Str = western_digits
Code = western_digits
CodeBlock = western_digits
Math = western_digits
