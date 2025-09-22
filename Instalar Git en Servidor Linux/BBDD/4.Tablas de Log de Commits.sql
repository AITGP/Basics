CREATE TABLE ecoopauditoria.GIT_COMMITS (
    commit_id VARCHAR2(40) PRIMARY KEY,
    author VARCHAR2(255),
    commit_date DATE,
    message CLOB
);

CREATE TABLE ecoopauditoria.GIT_FILES (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    commit_id VARCHAR2(40),
    status VARCHAR2(10),
    filename VARCHAR2(500),
    FOREIGN KEY (commit_id) REFERENCES GIT_COMMITS(commit_id)
);

CREATE TABLE ecoopauditoria.GIT_DIFFS (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    commit_id VARCHAR2(40),
    filename VARCHAR2(500),
    diff_text CLOB,
    FOREIGN KEY (commit_id) REFERENCES GIT_COMMITS(commit_id)
);