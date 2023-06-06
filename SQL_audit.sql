CREATE TABLE IF NOT EXISTS person
( id      BIGINT  PRIMARY KEY,
  name    VARCHAR NOT NULL,
  age     INTEGER NOT NULL DEFAULT 10,
  gender  VARCHAR DEFAULT 'female' NOT NULL,
  address VARCHAR
  );

ALTER TABLE person ADD CONSTRAINT ch_gender check ( gender in ('female','male') );

INSERT INTO person VALUES (1, 'Anna', 16, 'female', 'Moscow');
INSERT INTO person VALUES (2, 'Andrey', 21, 'male', 'Moscow');
INSERT INTO person VALUES (3, 'Kate', 33, 'female', 'Kazan');
INSERT INTO person VALUES (4, 'Denis', 13, 'male', 'Kazan');

CREATE TABLE IF NOT EXISTS person_audit (
    created    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    type_event CHAR(1)                  DEFAULT 'I'               NOT NULL,
    row_id     BIGINT                                             NOT NULL,
    name       VARCHAR                                                    ,            
    age        INTEGER                                                    ,           
    gender     VARCHAR                                                    ,               
    address    VARCHAR                                                    ,                
    CONSTRAINT ch_type_event CHECK ( type_event IN ('I', 'U', 'D'))
);                    
CREATE OR REPLACE FUNCTION fnc_trg_person_audit() RETURNS TRIGGER AS
$person_audit$
BEGIN
    IF (TG_OP = 'INSERT') THEN 
        INSERT INTO person_audit SELECT now(), 'I', NEW.id, NEW.name, NEW.age, NEW.gender, NEW.address;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO person_audit SELECT now(), 'U', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO person_audit SELECT now(), 'D', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address;
    END IF;
    RETURN NULL;
END;
$person_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_audit
    AFTER INSERT OR UPDATE OR DELETE 
    ON person 
    FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_audit();
