CREATE TABLE ecoopauditoria.GIT_COMMITS (
    commit_id VARCHAR2(100) PRIMARY KEY,
    author VARCHAR2(300),
    commit_date DATE,
    message VARCHAR2(500)
);

CREATE TABLE ecoopauditoria.GIT_FILES (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    commit_id VARCHAR2(100),
    status VARCHAR2(10),
    filename VARCHAR2(500)
);

CREATE TABLE ecoopauditoria.GIT_DIFFS (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    commit_id VARCHAR2(100),
    filename VARCHAR2(500),
    diff_text CLOB 
);

GRANT SELECT ON  ecoopauditoria.GIT_FILES TO ECOOPDESA;
GRANT SELECT ON  ecoopauditoria.GIT_DIFFS TO ECOOPDESA;
GRANT SELECT ON   ecoopauditoria.GIT_COMMITS TO ECOOPDESA;
