PRINT 'Commit 2: CP1252 SQL file from SSMS';
PRINT 'Encoding probe: £ café résumé';
PRINT 'Commit 3: change test.sql in CP1252.';
PRINT 'Commit 4: save as UTF-16 LE with BOM from SSMS.';
PRINT 'Commit 5: UTF-16 SQL change after .gitattributes.';
PRINT 'Commit 6: UTF-16 SQL change after attributes already exist.';
PRINT 'Commit 7: Validate with realistic SQL code.';
SELECT 1 AS Example;

GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [custom].[VW_GitHubEncodingDiffSmokeTest]
AS
SELECT
    CAST(1 AS int) AS SmokeTestID,
    N'UTF-16 LE with BOM' AS FileEncoding,
    N'GitHub readable diff after .gitattributes' AS DiffResult,
    SYSUTCDATETIME() AS GeneratedAtUtc;
GO

CREATE OR ALTER PROCEDURE [custom].[usp_GitHubEncodingDiffSmokeTest]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SmokeTestID,
        FileEncoding,
        DiffResult,
        GeneratedAtUtc
    FROM [custom].[VW_GitHubEncodingDiffSmokeTest];
END;
GO
