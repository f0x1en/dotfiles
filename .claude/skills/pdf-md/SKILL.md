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
- Warning `N unreadable glyphs (broken font map)` means the PDF fonts have no Unicode map
  (common in Persian PDFs printed from browsers). Text extraction cannot fix it. Use `--ocr`.
- `--ocr` uses `ocrmypdf` + `tesseract-ocr-fas` (installed). Languages: `PDFMD_LANG`, default `fas+eng`.
  `fas+eng` keeps English right but misreads some Persian words as Latin junk.
  `PDFMD_LANG=fas pdfmd --ocr ...` reads Persian better but breaks English words (`C++`, `PDF`).

## Homework convention

- Answers in `answers.md` next to the assignment PDF, Persian, name and student ID on line 3.
- Output file name follows the assignment (for example `StudentID-FirstName-LastName.pdf`).
