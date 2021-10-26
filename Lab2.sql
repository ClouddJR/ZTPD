-- ZAD 1

CREATE TABLE movies (
    id          NUMBER(12) PRIMARY KEY,
    title       VARCHAR2(400) NOT NULL,
    category    VARCHAR2(50),
    year        CHAR(4),
    cast        VARCHAR2(4000),
    director    VARCHAR2(4000),
    story       VARCHAR2(4000),
    price       NUMBER(5, 2),
    cover       BLOB,
    mime_type   VARCHAR2(50)
);

-- ZAD 2

INSERT INTO movies
    SELECT
        id,
        title,
        category,
        substr(year, 0, 4),
        cast,
        director,
        story,
        price,
        image,
        mime_type
    FROM
        descriptions left
        JOIN covers ON movie_id = id;
        
-- ZAD 3

SELECT
    title
FROM
    movies
WHERE
    cover IS NULL;
    
-- ZAD 4

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    cover IS NOT NULL;
    
-- ZAD 5

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    cover IS NULL;
    
-- ZAD 6

SELECT
    directory_name,
    directory_path
FROM
    all_directories;
    
-- ZAD 7

UPDATE movies
SET
    cover = empty_blob(),
    mime_type = 'image/jpeg'
WHERE
    id = 66;

COMMIT;
    
-- ZAD 8

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    id IN (
        65,
        66
    );
    
-- ZAD 9

DECLARE
    lobd   BLOB;
    fils   BFILE := bfilename('ZSBD_DIR', 'escape.jpg');
BEGIN
    SELECT
        cover
    INTO lobd
    FROM
        movies
    WHERE
        id = 66
    FOR UPDATE;

    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(lobd, fils, dbms_lob.getlength(fils));
    dbms_lob.fileclose(fils);
    COMMIT;
END;

-- ZAD 10

CREATE TABLE temp_covers (
    movie_id    NUMBER(12),
    image       BFILE,
    mime_type   VARCHAR2(50)
);

-- ZAD 11

INSERT INTO temp_covers VALUES (
    65,
    bfilename('ZSBD_DIR', 'eagles.jpg'),
    'image/jpeg'
);

-- ZAD 12

SELECT
    movie_id,
    dbms_lob.getlength(image) AS filesize
FROM
    temp_covers;
    
-- ZAD 13

DECLARE
    lobd   BLOB;
    fils   BFILE;
    mime   VARCHAR2(50);
BEGIN
    SELECT
        image,
        mime_type
    INTO
        fils,
        mime
    FROM
        temp_covers
    WHERE
        movie_id = 65;

    dbms_lob.createtemporary(lobd, true);
    dbms_lob.fileopen(fils, dbms_lob.file_readonly);
    dbms_lob.loadfromfile(lobd, fils, dbms_lob.getlength(fils));
    dbms_lob.fileclose(fils);
    UPDATE movies
    SET
        cover = lobd,
        mime_type = mime
    WHERE
        id = 65;

    dbms_lob.freetemporary(lobd);
    COMMIT;
END;

-- ZAD 14

SELECT
    id,
    title,
    dbms_lob.getlength(cover) AS filesize
FROM
    movies
WHERE
    id IN (
        65,
        66
    );
    
-- ZAD 15

DROP TABLE movies;

DROP TABLE temp_covers;