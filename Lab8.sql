-- ZAD1
CREATE TABLE cytaty
    AS
        SELECT
            *
        FROM
            zsbd_tools.cytaty;
            
-- ZAD2
SELECT
    *
FROM
    cytaty
WHERE
    lower(tekst) LIKE '%optymista%'
    AND lower(tekst) LIKE '%pesymista%';
    
-- ZAD3
CREATE INDEX cytaty_idx ON
    cytaty (
        tekst
    )
        INDEXTYPE IS ctxsys.context;
        
-- ZAD4
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'pesymista and optymista'
    ) > 0;
    
-- ZAD5
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'pesymista ~optymista'
    ) > 0;
    
-- ZAD6
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'near((pesymista, optymista), 3)'
    ) > 0;
    
-- ZAD7
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'near((pesymista, optymista), 10)'
    ) > 0;
    
-- ZAD8
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'życi%'
    ) > 0;
    
-- ZAD9
SELECT
    autor,
    tekst,
    score(
        1
    ) as score
FROM
    cytaty
WHERE
    contains(
        tekst, 'życi%', 1
    ) > 0;
    
-- ZAD10
SELECT
    autor,
    tekst,
    score(
        1
    ) as score
FROM
    cytaty
WHERE
    contains(
        tekst, 'życi%', 1
    ) > 0
ORDER BY
    score DESC
FETCH FIRST 1 ROW ONLY;

-- ZAD11
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'fuzzy(probelm)'
    ) > 0;
    
-- ZAD12
INSERT INTO cytaty VALUES (
    39,
    'Bertrand Russell',
    'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
);

COMMIT;

-- ZAD13
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'głupcy'
    ) > 0;
    
-- Indeks nie jest automatycznie odświeżany.

-- ZAD14
SELECT
    *
FROM
    dr$cytaty_idx$i;
    
-- ZAD15
DROP INDEX cytaty_idx;

CREATE INDEX cytaty_idx ON
    cytaty (
        tekst
    )
        INDEXTYPE IS ctxsys.context;
        
-- ZAD16
SELECT
    *
FROM
    dr$cytaty_idx$i
WHERE
    token_text = 'GŁUPCY';
    
SELECT
    *
FROM
    cytaty
WHERE
    contains(
        tekst, 'głupcy'
    ) > 0;
    
-- ZAD17
DROP INDEX cytaty_idx;

DROP TABLE cytaty;


-- Zaawansowane indeksowanie i wyszukiwanie

-- ZAD1
CREATE TABLE quotes
    AS
        SELECT
            *
        FROM
            zsbd_tools.quotes;
            
-- ZAD2
CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context;
        
-- ZAD3
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'work'
    ) > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, '$work'
    ) > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'working'
    ) > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, '$working'
    ) > 0;
    
-- ZAD4
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'it'
    ) > 0;

-- Brak wyników. "it" jest tzw. stopword.

-- ZAD5
SELECT
    *
FROM
    ctx_stoplists;
    
-- System wykorzysywał listę DEFAULT_STOPLIST.

-- ZAD6
SELECT
    *
FROM
    ctx_stopwords;
    
-- ZAD7
DROP INDEX quotes_idx;

CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context PARAMETERS ( 'stoplist CTXSYS.EMPTY_STOPLIST' );
        
-- ZAD8
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'it'
    ) > 0;
    
-- ZAD9
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'fool and humans'
    ) > 0;

-- ZAD10
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'fool and computer'
    ) > 0;
    
-- ZAD11
SELECT
    author,
    text
FROM
    quotes
WHERE
    contains(
        text, '(FOOL AND COMPUTER) WITHIN SENTENCE', 1
    ) > 0;
    
-- Błąd wynika z tego, że sekcja SENTENCE nie istnieje

-- ZAD12
DROP INDEX quotes_idx;

-- ZAD13
BEGIN
    ctx_ddl.create_section_group(
                                'nullgroup',
                                'NULL_SECTION_GROUP'
    );
    ctx_ddl.add_special_section(
                               'nullgroup',
                               'SENTENCE'
    );
    ctx_ddl.add_special_section(
                               'nullgroup',
                               'PARAGRAPH'
    );
END;

-- ZAD14
CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context PARAMETERS ( 'stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup' );

-- ZAD15
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, '(fool and humans) WITHIN SENTENCE'
    ) > 0;

SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, '(fool and computer) WITHIN SENTENCE'
    ) > 0;
    
-- ZAD16
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'humans'
    ) > 0;
    
-- Tak, ponieważ obecny lexer potraktował znak "-" jako znak niealfanumeryczny

-- ZAD17
DROP INDEX quotes_idx;

BEGIN
    ctx_ddl.create_preference(
                             'lex_z_m',
                             'BASIC_LEXER'
    );
    ctx_ddl.set_attribute(
                         'lex_z_m',
                         'printjoins',
                         '-'
    );
    ctx_ddl.set_attribute(
                         'lex_z_m',
                         'index_text',
                         'YES'
    );
END;

CREATE INDEX quotes_idx ON
    quotes (
        text
    )
        INDEXTYPE IS ctxsys.context PARAMETERS ( 'stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup LEXER lex_z_m' );
        
-- ZAD18
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'humans'
    ) > 0;
    
-- Tym razem brak cytatu zawierającego słowo "non-humans"

-- ZAD19
SELECT
    *
FROM
    quotes
WHERE
    contains(
        text, 'non\-humans'
    ) > 0;
    
--ZAD20
BEGIN
    ctx_ddl.drop_preference('lex_z_m');
    ctx_ddl.drop_section_group('nullgroup');
END;

DROP TABLE quotes;