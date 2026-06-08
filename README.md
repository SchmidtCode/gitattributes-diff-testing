# gitattributes-diff-testing

Minimal repro for GitHub's handling of SQL files saved by SQL Server Management Studio (SSMS) as Western European Windows code page 1252.

## Point Of This Repo

SSMS can save `.sql` files as `Western European (Windows) - Code page 1252`. GitHub appears to support `.gitattributes` content-encoding hints for some file types, but may still fail to show useful diffs for SSMS-style SQL files.

This repo is intended to prove the gap with a small commit history a maintainer can inspect quickly.

## Test Pattern

Compare GitHub's rendered diff against local Git output for each commit:

```powershell
git check-attr -a -- test.sql
git diff HEAD~1 HEAD -- test.sql
```

Inspect the first bytes of the file:

```powershell
Format-Hex -Path .\test.sql -Count 16
```

For plain ASCII-range SQL text, CP1252, UTF-8, and ASCII can look identical in this output. To prove the encoding matters, include at least one CP1252-specific character in the SQL file, such as a pound sign or accented character.

Example CP1252 bytes to look for:

```text
A3    # pound sign
E9    # e acute
```

## Repro Commits

### 1. Initial Repo

README only.

### 2. Add `test.sql` From SSMS

Adds a `.sql` file saved from SSMS as Western European Windows code page 1252, before any `.gitattributes` rule exists.

Expected result:

- GitHub may render non-ASCII CP1252 characters incorrectly or fail to render a useful text diff.

Observed result:

- TODO

### 3. Add `.gitattributes` And Modify `test.sql`

Adds:

```gitattributes
# set content encodings
*     encoding=UTF-8
*.sql encoding=CP1252 text
```

Then makes a small SQL change.

Expected result:

- `git check-attr` should show `test.sql` matched with `encoding=CP1252` and `text`.
- GitHub should ideally use that encoding hint to render a readable SQL diff.
- If GitHub does not honor the hint for diffs, the SQL diff may still render incorrectly or appear binary-like.

Observed result:

- TODO

### 4. Modify `test.sql` Again

Changes the SQL file after `.gitattributes` already exists.

Expected result:

- If GitHub honors the `encoding=CP1252 text` rule for diffs, this should render as readable SQL.
- If not, the diff remains unreadable or binary-like.

Observed result:

- TODO

## Evidence Summary

| Commit | Scenario | Local Git | GitHub |
| --- | --- | --- | --- |
| 2 | CP1252 SQL, no attributes | TODO | TODO |
| 3 | Add `encoding=CP1252 text` and modify SQL | TODO | TODO |
| 4 | Modify SQL after encoding rule exists | TODO | TODO |

## Why This Matters

SQL Server users often review database changes through GitHub pull requests. If GitHub cannot render diffs for SSMS-generated CP1252 SQL files even when `.gitattributes` declares the file encoding, reviewers lose normal code review for a common Microsoft SQL workflow.
