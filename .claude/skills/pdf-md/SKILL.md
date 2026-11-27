---
name: pdf-md
description: Convert between PDF and Markdown on this machine, including Persian (RTL) text. Use when the user wants md -> pdf (homework, reports to send), pdf -> md (read or edit an assignment PDF), or a Persian PDF that renders or extracts wrong.
---

# pdf-md

Local commands in `~/.local/bin` (tracked in the dotfiles repo): `mdpdf`, `pdfmd`, `pdf-fixmap`.

## Markdown -> PDF: `mdpdf`

```sh
mdpdf input.md [output.pdf]
```

- pandoc -> HTML -> headless chromium. Fonts: Inter (Latin), Vazirmatn (Persian), JetBrains Mono (code).
  Chromium was kept after a web search: it shapes and orders Persian correctly with no LaTeX setup.
- Each block (p, li, ul, ol, headings, cells) gets its direction from its majority script, so
  "MSVC برای ..." is RTL. Pure-English blocks stay LTR.
- Code blocks: each line picks its own direction; Persian comments fall back to Vazirmatn.
- Persian digits are converted to Western digits.
- Check the result: `mutool draw -r 70 -o page%d.png out.pdf`, then look at the PNGs.
- Round-trip check: `pdfmd out.pdf -` and compare the Persian words with the source.

## PDF -> Markdown: `pdfmd`

```sh
pdfmd [--ocr] input.pdf [output.md]   # output '-' = stdout
```

Base: `pdftotext` (poppler) keeps Persian word order; pymupdf4llm, markitdown and MuPDF text
reverse RTL words (tested). Output is plain paragraphs: headings, tables and lists are not
recovered. Bidi control marks stay in the output on purpose (they place numbers and punctuation).

Persian text triggers `pdf-fixmap` (repairs a copy of the PDF's ToUnicode maps; page content
unchanged), then these fixes. Each one solves a case seen in real PDFs:

| Problem | Seen in | Fix |
|---|---|---|
| Glyphs map to U+FFFD / U+06FF ("تحق�ق") | Firefox/cairo prints (Quera) | `pdf-fixmap`: OCR lines with broken glyphs (tesseract fas, tessdata_best), vote per glyph |
| Multi-char glyphs reversed ("ال" for "لا", "ٔه") | MS Word | `pdf-fixmap` pre-reverses Persian multi-char map entries (poppler bug 55977) |
| "لا" ligature as one glyph comes out "ال" | Chromium (Vazirmatn) | `pdfmd` swaps only when `mutool trace` (raw glyphs, x order) has the swapped word |
| Vowel marks before their letter ("فّرار") | Chromium | marks placed per the trace word (mark attached to the letter it sits over) |
| Half-spaces (ZWNJ) lost | all | from letter shapes; for Word (plain-letter maps) `pdf-fixmap` learns each glyph's shape from word ends |
| Brackets mirrored / split around English | all | `)…(` and `)‪ RISC (…‬` rebuilt to `(…)` |

- Debug: `FIXMAP_DEBUG=1 pdf-fixmap in.pdf out.pdf` prints OCR votes and misses.
- Known gap: a font that maps letter shapes to plain letters *and* also has shaped entries
  (some cairo PDFs) loses ZWNJ for those plain glyphs ("نرمافزار").
- `--ocr` is for scans with no text layer: full OCR with `ocrmypdf` + `tesseract-ocr-fas`.
  Languages: `PDFMD_LANG`, default `fas+eng`. OCR makes word errors; prefer the text layer.

## Homework convention

- Answers in `answers.md` next to the assignment PDF, Persian, name and student ID on line 3.
- Output file name follows the assignment (for example `StudentID-FirstName-LastName.pdf`).
