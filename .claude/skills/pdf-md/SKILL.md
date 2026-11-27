---
name: pdf-md
description: Convert between PDF and Markdown on this machine, including Persian (RTL) text. Use when the user wants md -> pdf (homework, reports to send), pdf -> md (read or edit an assignment PDF), or a Persian PDF that renders or extracts wrong.
---

# pdf-md

Two local commands in `~/.local/bin` (tracked in the dotfiles repo).

## Markdown -> PDF: `mdpdf`

```sh
mdpdf input.md [output.pdf]
```

- pandoc -> HTML -> headless chromium. Fonts: Inter (Latin), Vazirmatn (Persian), JetBrains Mono (code).
- Each block picks its own direction from its first strong letter (`dir="auto"`).
  A Persian line that starts with a Latin word (`MSVC ...`, `**volatile**: ...`) renders LTR.
  Fix: start the line with a Persian word (`کامپایلر MSVC ...`).
- Do not put Persian inside code blocks: the mono font has no Persian shaping. Use English comments.
- Persian digits are converted to Western digits.
- Check the result: `mutool draw -r 70 -o page%d.png out.pdf`, then look at the PNGs.

## PDF -> Markdown: `pdfmd`

```sh
pdfmd [--ocr] input.pdf [output.md]   # output '-' = stdout
```

- Uses `pdftotext` (poppler). It keeps Persian word order; pymupdf4llm and markitdown reverse RTL words (tested).
- Output is plain paragraphs. Headings, tables and lists are not recovered; add Markdown by hand.
- Bidi control marks stay in the output on purpose: they place punctuation and numbers correctly.
- Broken font maps are repaired automatically. Some Persian PDFs printed from a browser map
  glyphs to U+FFFD or U+06FF ("تحق�ق"). `pdfmd` then runs `pdf-fixmap`: it OCRs only the lines
  with broken glyphs, votes per glyph, and fixes the PDF's ToUnicode map. Result: exact text.
  Manual use: `pdf-fixmap in.pdf fixed.pdf` (`FIXMAP_DEBUG=1` prints the votes).
  It uses `$HOME/.local/share/tessdata-best` (tessdata_best fas/eng) if present, else the system models.
- Half-spaces (ZWNJ) are not stored in PDFs. `pdfmd` restores them from the letter shapes
  (a joining letter followed directly by a letter in its initial shape), and `pdf-fixmap`
  writes repaired letters in their shaped form so this still works.
- Brackets around Persian-only text come out mirrored from pdftotext; `pdfmd` flips `)…(` back.
- Known issue: PDFs set in Vazirmatn (including `mdpdf` output) extract `لا` as `ال`
  (the font draws the ligature as two glyphs in visual order). Rendering is fine.
- `--ocr` is for scans with no text layer: full OCR with `ocrmypdf` + `tesseract-ocr-fas` (installed).
  Languages: `PDFMD_LANG`, default `fas+eng`. OCR makes word errors; prefer the text layer when there is one.

## Homework convention

- Answers in `answers.md` next to the assignment PDF, Persian, name and student ID on line 3.
- Output file name follows the assignment (for example `StudentID-FirstName-LastName.pdf`).
