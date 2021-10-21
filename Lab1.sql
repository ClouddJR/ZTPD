-- ZAD 1
CREATE TYPE samochod AS OBJECT (
    marka          VARCHAR2(20),
    model          VARCHAR2(20),
    kilometyr      NUMBER,
    data_produkcji DATE,
    cena           NUMBER(10, 2)
);

CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES (
    NEW samochod ( 'FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000 )
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'FORD', 'MONDEO', 80000, TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000 )
);

INSERT INTO samochody VALUES (
    NEW samochod ( 'MAZDA', '323', 12000, TO_DATE('29-09-2000', 'DD-MM-YYYY'), 52000 )
);

SELECT
    *
FROM
    samochody;

-- ZAD 2
CREATE TABLE wlasciciele (
    imie     VARCHAR(100),
    nazwisko VARCHAR(100),
    auto     samochod
);

INSERT INTO wlasciciele VALUES (
    'JAN',
    'KOWALSKI',
        NEW samochod ( 'FIAT', 'SEICENTO', 30000, TO_DATE('02-12-0010', 'DD-MM-YYYY'), 1950 )
);

INSERT INTO wlasciciele VALUES (
    'ADAM',
    'NOWAK',
        NEW samochod ( 'OPEL', 'ASTRA', 34000, TO_DATE('01-06-0009', 'DD-MM-YYYY'), 33700 )
);

SELECT
    *
FROM
    wlasciciele;
    
-- ZAD 3
ALTER TYPE samochod
    ADD
        MEMBER FUNCTION wartosc RETURN NUMBER
    CASCADE;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN power(0.9, extract(YEAR FROM current_date) - extract(YEAR FROM data_produkcji)) * cena;
    END wartosc;

END;

-- ZAD 4
ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN power(0.9, extract(YEAR FROM current_date) - extract(YEAR FROM data_produkcji)) * cena;
    END wartosc;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
    BEGIN
        RETURN ( extract(YEAR FROM current_date) - extract(YEAR FROM data_produkcji) ) + ceil(kilometry / 10000);
    END odwzoruj;

END;

-- ZAD 5
CREATE TYPE wlasciciel AS OBJECT (
    imie     VARCHAR2(20),
    nazwisko VARCHAR2(20)
);

CREATE TABLE wlasciciele_obj OF wlasciciel;

INSERT INTO wlasciciele_obj VALUES (
    NEW wlasciciel ( 'JAN', 'KOWALSKI' )
);

INSERT INTO wlasciciele_obj VALUES (
    NEW wlasciciel ( 'JAN', 'KOZLOWSKI' )
);

ALTER TYPE samochod ADD ATTRIBUTE wlasc REF wlasciciel
    CASCADE;

UPDATE samochody s
SET
    s.wlasc = (
        SELECT
            ref(w)
        FROM
            wlasciciele_obj w
        WHERE
            w.nazwisko = 'KOWALSKI'
    );
    
-- ZAD 7
DECLARE
    TYPE t_ksiazki IS
        VARRAY(10) OF VARCHAR2(20);
    moje_ksiazki t_ksiazki := t_ksiazki('');
BEGIN
    moje_ksiazki(1) := 'Harry Potter';
    moje_ksiazki.extend(9);
    FOR i IN 2..10 LOOP
        moje_ksiazki(i) := 'KSIAZKA' || i;
    END LOOP;

    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;

    moje_ksiazki.trim(2);
    FOR i IN moje_ksiazki.first()..moje_ksiazki.last() LOOP
        dbms_output.put_line(moje_ksiazki(i));
    END LOOP;

    moje_ksiazki.extend();
    moje_ksiazki(9) := 9;
    moje_ksiazki.DELETE();
    dbms_output.put_line('Limit: ' || moje_ksiazki.limit());
    dbms_output.put_line('Liczba elementow: ' || moje_ksiazki.count());
END;

-- ZAD 9
DECLARE
    TYPE t_miesiace IS
        TABLE OF VARCHAR2(20);
    moje_miesiace t_miesiace := t_miesiace();
BEGIN
    moje_miesiace.extend(12);
    moje_miesiace(1) := 'STYCZEŃ';
    moje_miesiace(2) := 'LUTY';
    moje_miesiace(3) := 'MARZEC';
    moje_miesiace(4) := 'KWIECIEŃ';
    moje_miesiace(5) := 'MAJ';
    moje_miesiace(6) := 'CZERWIEC';
    moje_miesiace(7) := 'LIPIEC';
    moje_miesiace(8) := 'SIERPIEŃ';
    moje_miesiace(9) := 'WRZESIEŃ';
    moje_miesiace(10) := 'PAŹDZIERNIK';
    moje_miesiace(11) := 'LISTOPAD';
    moje_miesiace(12) := 'GRUDZIEŃ';
    moje_miesiace.trim(3);
    FOR i IN moje_miesiace.first()..moje_miesiace.last() LOOP
        dbms_output.put_line(moje_miesiace(i));
    END LOOP;

END;

-- ZAD 11
CREATE TYPE produkty AS
    TABLE OF VARCHAR2(20);

CREATE TYPE zakup AS OBJECT (
    id               VARCHAR(10),
    koszyk_produktow produkty
);

CREATE TABLE zakupy OF zakup
NESTED TABLE koszyk_produktow STORE AS tab_koszyk_produktow;

INSERT INTO zakupy VALUES (
    1,
    produkty('PIELUSZKI', 'PIWO')
);

INSERT INTO zakupy VALUES (
    2,
    produkty('PIWO', 'CZEKOLADA')
);

INSERT INTO zakupy VALUES (
    3,
    produkty('SER', 'MLEKO')
);

DELETE FROM zakupy
WHERE
    id IN (
        SELECT
            id
        FROM
            zakupy z, TABLE ( z.koszyk_produktow ) p
        WHERE
            p.column_value = 'PIWO'
    );
    
-- ZAD 22
CREATE TABLE pisarze (
    id_pisarza NUMBER PRIMARY KEY,
    nazwisko   VARCHAR2(20),
    data_ur    DATE
);

CREATE TABLE ksiazki (
    id_ksiazki   NUMBER PRIMARY KEY,
    id_pisarza   NUMBER NOT NULL
        REFERENCES pisarze,
    tytul        VARCHAR2(50),
    data_wydania DATE
);

INSERT INTO pisarze VALUES (
    10,
    'SIENKIEWICZ',
    DATE '1880-01-01'
);

INSERT INTO pisarze VALUES (
    20,
    'PRUS',
    DATE '1890-04-12'
);

INSERT INTO pisarze VALUES (
    30,
    'ZEROMSKI',
    DATE '1899-09-11'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydania
) VALUES (
    10,
    10,
    'OGNIEM I MIECZEM',
    DATE '1990-01-05'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydania
) VALUES (
    20,
    10,
    'POTOP',
    DATE '1975-12-09'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydania
) VALUES (
    30,
    10,
    'PAN WOLODYJOWSKI',
    DATE '1987-02-15'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydania
) VALUES (
    40,
    20,
    'FARAON',
    DATE '1948-01-21'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydania
) VALUES (
    50,
    20,
    'LALKA',
    DATE '1994-08-01'
);

INSERT INTO ksiazki (
    id_ksiazki,
    id_pisarza,
    tytul,
    data_wydania
) VALUES (
    60,
    30,
    'PRZEDWIOSNIE',
    DATE '1938-02-02'
);

CREATE TYPE ksiazki_tab AS
    TABLE OF VARCHAR2(100);

CREATE TYPE pisarz AS OBJECT (
    id_pisarza NUMBER,
    nazwisko   VARCHAR2(20),
    data_ur    DATE,
    ksiazki    ksiazki_tab,
    MEMBER FUNCTION liczba_ksiazek RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY pisarz AS
    MEMBER FUNCTION liczba_ksiazek RETURN NUMBER IS
    BEGIN
        RETURN ksiazki.count();
    END liczba_ksiazek;

END;

CREATE TYPE ksiazka AS OBJECT (
    id_ksiazki   NUMBER,
    autor        REF pisarz,
    tytul        VARCHAR2(50),
    data_wydania DATE,
    MEMBER FUNCTION wiek RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY ksiazka AS
    MEMBER FUNCTION wiek RETURN NUMBER IS
    BEGIN
        RETURN extract(YEAR FROM current_date) - extract(YEAR FROM data_wydania);
    END wiek;

END;

CREATE OR REPLACE VIEW ksiazki_v
    OF ksiazka WITH OBJECT IDENTIFIER ( id_ksiazki )
AS
    SELECT
        id_ksiazki,
        make_ref(pisarze_v, id_pisarza),
        tytul,
        data_wydania
    FROM
        ksiazki;

CREATE OR REPLACE VIEW pisarze_v
    OF pisarz WITH OBJECT IDENTIFIER ( id_pisarza )
AS
    SELECT
        id_pisarza,
        nazwisko,
        data_ur,
        CAST(MULTISET(
            SELECT
                tytul
            FROM
                ksiazki
            WHERE
                id_pisarza = p.id_pisarza
        ) AS ksiazki_tab)
    FROM
        pisarze p;
        
-- ZAD 23
CREATE TYPE auto AS OBJECT (
    marka          VARCHAR2(20),
    model          VARCHAR2(20),
    kilometry      NUMBER,
    data_produkcji DATE,
    cena           NUMBER(10, 2),
    MEMBER FUNCTION wartosc RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE BODY auto AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek    NUMBER;
        wartosc NUMBER;
    BEGIN
        wiek := round(months_between(sysdate, data_produkcji) / 12);
        wartosc := cena - ( wiek * 0.1 * cena );
        IF ( wartosc < 0 ) THEN
            wartosc := 0;
        END IF;
        RETURN wartosc;
    END wartosc;

END;

CREATE TYPE auto_osobowe UNDER auto (
    liczba_miejsc    NUMBER,
    czy_klimatyzacja CHAR(1),
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_osobowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := ( self AS auto ).wartosc();
        IF ( czy_klimatyzacja = '1' ) THEN
            wartosc := wartosc * 1.5;
        END IF;

        RETURN wartosc;
    END;

END;

CREATE TYPE auto_ciezarowe UNDER auto (
    maksymalna_ladownosc_kg NUMBER,
    OVERRIDING MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY auto_ciezarowe AS OVERRIDING
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wartosc NUMBER;
    BEGIN
        wartosc := ( self AS auto ).wartosc();
        IF ( maksymalna_ladownosc_kg > 10000 ) THEN
            wartosc := wartosc * 2;
        END IF;
        RETURN wartosc;
    END;

END;

CREATE TABLE auta OF auto;

INSERT INTO auta VALUES ( auto('FIAT', 'BRAVA', 60000, DATE '1999-11-30', 25000) );

INSERT INTO auta VALUES ( auto('FORD', 'MONDEO', 80000, DATE '1997-05-10', 45000) );

INSERT INTO auta VALUES ( auto('MAZDA', '323', 12000, DATE '2000-09-22', 52000) );

INSERT INTO auta VALUES ( auto_osobowe('SKODA', 'FABIA', 20000, DATE '2020-11-30', 25000,
                                       5, '1') );

INSERT INTO auta VALUES ( auto_osobowe('AUDI', 'A3', 45000, DATE '2020-11-30', 55000,
                                       5, '0') );

INSERT INTO auta VALUES ( auto_ciezarowe('VOLVO', 'FH4', 80000, DATE '2020-11-30', 50000,
                                         8000) );

INSERT INTO auta VALUES ( auto_ciezarowe('MAN', 'TGE', 120000, DATE '2020-11-30', 50000,
                                         12000) );

SELECT
    a.marka,
    a.wartosc()
FROM
    auta a;