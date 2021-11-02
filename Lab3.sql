--ZAD 1
CREATE TABLE dokumenty (
    id       NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

--ZAD 2
DECLARE
    lobd CLOB;
    i    INTEGER;
BEGIN
    INSERT INTO dokumenty VALUES (
        1,
        empty_clob()
    );

    SELECT
        dokument
    INTO lobd
    FROM
        dokumenty
    WHERE
        id = 1
    FOR UPDATE;

    FOR i IN 1..10000 LOOP
        dbms_lob.append(lobd, 'Oto tekst. ');
    END LOOP;

    COMMIT;
END;

--ZAD 3A
SELECT
    *
FROM
    dokumenty;

--ZAD 3B
SELECT
    upper(dokument)
FROM
    dokumenty;

--ZAD 3C
SELECT
    length(dokument)
FROM
    dokumenty;

--ZAD 3D
SELECT
    dbms_lob.getlength(dokument)
FROM
    dokumenty;

--ZAD 3E
SELECT
    substr(dokument, 5, 1000)
FROM
    dokumenty;

--ZAD 3F
SELECT
    dbms_lob.substr(dokument, 1000, 5)
FROM
    dokumenty;

--ZAD 4
INSERT INTO dokumenty VALUES (
    2,
    empty_clob()
);

--ZAD 5
INSERT INTO dokumenty VALUES (
    3,
    NULL
);

COMMIT;

--ZAD 6
SELECT
    *
FROM
    dokumenty;

SELECT
    upper(dokument)
FROM
    dokumenty;

SELECT
    length(dokument)
FROM
    dokumenty;

SELECT
    dbms_lob.getlength(dokument)
FROM
    dokumenty;

SELECT
    substr(dokument, 5, 1000)
FROM
    dokumenty;

SELECT
    dbms_lob.substr(dokument, 1000, 5)
FROM
    dokumenty;

--ZAD 7
SELECT
    directory_name,
    directory_path
FROM
    all_directories;

--ZAD 8
DECLARE
    lobd    CLOB;
    fils    BFILE := bfilename('ZSBD_DIR', 'dokument.txt');
    doffset INTEGER := 1;
    soffset INTEGER := 1;
    langctx INTEGER := 0;
    warn    INTEGER := NULL;
BEGIN
    SELECT
        dokument
    INTO lobd
    FROM
        dokumenty
    WHERE
        id = 2
    FOR UPDATE;

    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadclobfromfile(lobd, fils, dbms_lob.lobmaxsize, doffset, soffset,
                             0, langctx, warn);

    dbms_lob.fileclose(fils);
    COMMIT;
    dbms_output.put_line('Status: ' || warn);
END;

--ZAD 9
UPDATE dokumenty
SET
    dokument = to_clob(bfilename('ZSBD_DIR', 'dokument.txt'))
WHERE
    id = 3;

--ZAD 10
SELECT
    *
FROM
    dokumenty;

--ZAD 11
SELECT
    dbms_lob.getlength(dokument)
FROM
    dokumenty;

--ZAD 12
DROP TABLE dokumenty;

--ZAD 13
CREATE OR REPLACE PROCEDURE clob_censor (
    lobd    IN OUT CLOB,
    pattern VARCHAR2
) IS
    position     INTEGER;
    replace_with VARCHAR2(100);
    i            INTEGER;
BEGIN
    FOR i IN 1..length(pattern) LOOP
        replace_with := replace_with || '.';
    END LOOP;

    LOOP
        position := dbms_lob.instr(lobd, pattern, 1, 1);
        EXIT WHEN position = 0;
        dbms_lob.write(lobd, length(pattern), position, replace_with);
    END LOOP;

END clob_censor;

--ZAD 14
CREATE TABLE biographies_copy
    AS
        SELECT
            *
        FROM
            zsbd_tools.biographies;

DECLARE
    lobd CLOB;
BEGIN
    SELECT
        bio
    INTO lobd
    FROM
        biographies_copy
    WHERE
        id = 1
    FOR UPDATE;

    clob_censor(lobd, 'Cimrman');
    COMMIT;
END;

SELECT
    *
FROM
    biographies_copy;

--ZAD 15
DROP TABLE biographies_copy;