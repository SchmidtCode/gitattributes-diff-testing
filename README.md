# gitattributes-diff-testing

Minimal repro for GitHub diff behavior with SQL files saved from SQL Server Management Studio (SSMS) using different encodings.

## Point Of This Repo

SSMS can save `.sql` files as `Western European (Windows) - Code page 1252` or as `Unicode - Code page 1200` / UTF-16 LE with BOM.

This repo checks which SSMS encodings GitHub can diff correctly, and whether `.gitattributes` encoding hints could improve SQL review in GitHub pull requests.

For the UTF-16 test, use `Unicode - Code page 1200`. Do not use `Unicode (Big-Endian) - Code page 1201`.

## Test Pattern

For each commit, compare GitHub's rendered diff with local Git output:

```powershell
git check-attr -a -- test.sql
git diff HEAD~1 HEAD -- test.sql
Format-Hex -Path .\test.sql -Count 160
```

Encoding clues:

```text
A3       CP1252 pound sign
E9       CP1252 e acute
FF FE    UTF-16 LE BOM
```

## Repro Commits

### 1. Initial Repo

README only.

### 2. Add CP1252 SQL From SSMS

Adds `test.sql` saved from SSMS as `Western European (Windows) - Code page 1252`.

Expected result:

- GitHub renders the file as a readable SQL diff.
- Non-ASCII probe characters may reveal decoding differences.

Observed result:

- Local Git and GitHub both rendered the diff correctly.

### 3. Modify CP1252 SQL

Makes a normal SQL change while keeping the file saved as CP1252.

Expected result:

- Local Git renders a text diff.
- GitHub renders a readable SQL diff.

Observed result:

- Local Git and GitHub both rendered the diff correctly.

### 4. Save As UTF-16 LE With BOM

Re-save or replace `test.sql` from SSMS using `Unicode - Code page 1200`, then make a small SQL change.

Expected result:

- `Format-Hex` starts with `FF FE`.
- Local Git or GitHub may treat the file as binary or fail to render a useful text diff.

Observed result:

- `Format-Hex` starts with `FF FE`.
- Local Git reports `Binary files a/test.sql and b/test.sql differ`.
- GitHub shows `Binary file not shown`.

### 5. Add `.gitattributes` Working Tree Encoding

Adds:

```gitattributes
# Default text handling
* text=auto

# SSMS SQL files saved as UTF-16 little-endian with BOM
*.sql text working-tree-encoding=UTF-16LE-BOM eol=crlf diff
```

Then runs:

```powershell
git add --renormalize test.sql
```

Expected result:

- `git check-attr` shows `test.sql` matched with `working-tree-encoding=UTF-16LE-BOM`, `text`, `eol=crlf`, and `diff`.
- Git stores the file as readable normalized text while the working tree remains UTF-16 LE with BOM.
- The first renormalization diff may show the old side as UTF-16 bytes and the new side as readable SQL.

Observed result:

- Local Git showed a readable normalized SQL side after `git add --renormalize test.sql`.
- The working tree file still starts with `FF FE`.
- GitHub still shows `Binary file not shown`.

### 6. Modify UTF-16 SQL After Attributes Exist

Makes another small SQL change after `.gitattributes` is already present in the base commit.

Expected result:

- Local Git should render a clean SQL text diff.
- The working tree file should still start with `FF FE`.
- GitHub should ideally render the SQL diff if it honors the Git attributes.

Observed result:

- `Format-Hex` still starts with `FF FE`.
- Local Git renders a clean readable SQL diff.
- GitHub result: TODO

## Evidence Summary

| Commit | Scenario | Local Git | GitHub |
| --- | --- | --- | --- |
| 2 | Add CP1252 SQL | Pass | Pass |
| 3 | Modify CP1252 SQL | Pass | Pass |
| 4 | Save/modify as UTF-16 LE BOM | Binary | Binary file not shown |
| 5 | Add UTF-16 working tree encoding | Renormalized text | Binary file not shown |
| 6 | Modify UTF-16 SQL after attributes exist | Pass | TODO |

## Why This Matters

SQL Server users review database changes in GitHub pull requests. If GitHub cannot render SSMS-generated SQL diffs for common encodings, reviewers lose normal code review for a common Microsoft SQL workflow.
