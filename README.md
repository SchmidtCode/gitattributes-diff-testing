# gitattributes-diff-testing

Minimal repro for GitHub diff behavior with SQL files saved from SQL Server Management Studio (SSMS) using different encodings.

## Point Of This Repo

SSMS can save `.sql` files as `Western European (Windows) - Code page 1252` or as `Unicode - Code page 1200` / UTF-16 LE with BOM.

This repo checks which SSMS encodings GitHub can diff correctly, and whether `.gitattributes` encoding hints could improve SQL review in GitHub pull requests.

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

- TODO

### 3. Modify CP1252 SQL

Makes a normal SQL change while keeping the file saved as CP1252.

Expected result:

- Local Git renders a text diff.
- GitHub renders a readable SQL diff.

Observed result:

- TODO

### 4. Save As UTF-16 LE With BOM

Re-save or replace `test.sql` from SSMS using `Unicode - Code page 1200`, then make a small SQL change.

Expected result:

- `Format-Hex` starts with `FF FE`.
- Local Git or GitHub may treat the file as binary or fail to render a useful text diff.

Observed result:

- TODO

### 5. Add `.gitattributes` Encoding Hint

Adds:

```gitattributes
# set content encodings
*     encoding=UTF-8
*.sql encoding=UTF-16LE text
```

Then makes another small SQL change.

Expected result:

- `git check-attr` shows `test.sql` matched with `encoding=UTF-16LE` and `text`.
- GitHub should ideally use that hint to render a readable SQL diff.

Observed result:

- TODO

## Evidence Summary

| Commit | Scenario | Local Git | GitHub |
| --- | --- | --- | --- |
| 2 | Add CP1252 SQL | TODO | TODO |
| 3 | Modify CP1252 SQL | TODO | TODO |
| 4 | Save/modify as UTF-16 LE BOM | TODO | TODO |
| 5 | Add UTF-16 `.gitattributes` hint | TODO | TODO |

## Why This Matters

SQL Server users review database changes in GitHub pull requests. If GitHub cannot render SSMS-generated SQL diffs for common encodings, reviewers lose normal code review for a common Microsoft SQL workflow.
