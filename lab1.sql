SET LIN 400
SET SERVEROUTPUT ON FORMAT WRAPPED;
SET verify OFF
accept entSchemeName CHAR prompt 'Enter scheme name: '

DECLARE
    textConstName varchar2(32) := 'Имя ограничения';
    textType      varchar2(3)  := 'Тип';
    textTableName varchar2(32) := 'Имя таблицы';
    textColName   varchar2(32) := 'Имя столбца';
    textConstdesc varchar2(32) := 'Текст ограничения';
    num           number       := 1;
    schemeText    varchar2(8)  := 'Scheme: ';
    textNo        varchar2(16) := 'No.';
    checkScheme   NUMBER       := 0;
    noUser EXCEPTION;
    CURSOR RESULT IS
        SELECT ALL_CONSTRAINTS.constraint_name  AS const_name
             , ALL_CONSTRAINTS.constraint_type  AS constType
             , ALL_CONSTRAINTS.table_name       AS tabName
             , ALL_CONS_COLUMNS.column_name     AS colName
             , ALL_CONSTRAINTS.search_condition AS searchCond
        FROM ALL_CONSTRAINTS
                 JOIN ALL_CONS_COLUMNS ON ALL_CONS_COLUMNS.constraint_name = ALL_CONSTRAINTS.constraint_name
        WHERE ALL_CONSTRAINTS.constraint_type = 'C'
          AND ALL_CONSTRAINTS.owner = q'[&entSchemeName]';

BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD(schemeText, 8) || '' || RPAD(q'[&entSchemeName]', 32));
    SELECT count(owner) INTO checkScheme FROM dba_tables WHERE owner = q'[&entSchemeName]';

    IF checkScheme = 0 THEN
        RAISE noUser;
    ELSE
        DBMS_OUTPUT.PUT_LINE(RPAD(textNo, 3) || ' ' || RPAD(textConstName, 32) || ' ' || RPAD(textType, 3) || ' ' ||
                             RPAD(textTableName, 32) || ' ' || RPAD(textColName, 32) || ' ' || RPAD(textConstdesc, 96));

        DBMS_OUTPUT.PUT_LINE(RPAD('-', 3, '-') || ' ' || RPAD('-', 32, '-') || ' ' || RPAD('-', 3, '-') || ' ' ||
                             RPAD('-', 32, '-') || ' ' || RPAD('-', 32, '-') || ' ' || RPAD('-', 96, '-'));
        FOR row IN RESULT
            LOOP
                DBMS_OUTPUT.PUT_LINE(
                            RPAD(num, 3) || ' ' || RPAD(row.const_name, 32) || ' ' || RPAD(row.constType, 3) || ' ' ||
                            RPAD(row.tabName, 32) || ' ' || RPAD(row.colName, 32) || ' ' || RPAD(row.searchCond, 96));

                num := num + 1;
            END LOOP;
    END
        IF;
EXCEPTION
    WHEN noUser THEN raise_application_error(- 20001, 'No users with that name');
    WHEN
        OTHERS THEN raise_application_error(- 20000, 'ERROR! CHECK AND FIX YOUR REQUEST!');
END;
/
