CREATE TABLE cur_exchange (
id_number       NUMBER PRIMARY KEY,
currency        VARCHAR2(10) NOT NULL,
exchange_rate   NUMBER NOT NULL,
exchange_date   DATE DEFAULT SYSDATE
);



