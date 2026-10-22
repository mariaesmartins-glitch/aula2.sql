CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    total_compras NUMERIC(10, 2) DEFAULT 0.00
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);


CREATE OR REPLACE FUNCTION fn_atualiza_total_cliente()
RETURNS TRIGGER AS $$
DECLARE
    v_cliente_id INT;
BEGIN
   
    IF (TG_OP = 'DELETE') THEN
        v_cliente_id := OLD.cliente_id;
    
    ELSE
        v_cliente_id := NEW.cliente_id;
    END IF;

    UPDATE clientes
    SET total_compras = COALESCE((
        SELECT SUM(valor_total) 
        FROM pedidos 
        WHERE cliente_id = v_cliente_id
    ), 0.00)
    WHERE id = v_cliente_id;

    IF (TG_OP = 'UPDATE' AND OLD.cliente_id IS DISTINCT FROM NEW.cliente_id) THEN
        UPDATE clientes
        SET total_compras = COALESCE((
            SELECT SUM(valor_total) 
            FROM pedidos 
            WHERE cliente_id = OLD.cliente_id
        ), 0.00)
        WHERE id = OLD.cliente_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualiza_total_pedidos
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_total_cliente();

INSERT INTO clientes (nome) VALUES ('Paulo Antunes'), ('Ana Souza');

SELECT * FROM clientes;

INSERT INTO pedidos (cliente_id, valor_total) VALUES (1, 150.00);

INSERT INTO pedidos (cliente_id, valor_total) VALUES (1, 50.00);

INSERT INTO pedidos (cliente_id, valor_total) VALUES (2, 300.00);

SELECT * FROM clientes;

UPDATE pedidos SET valor_total = 100.00 WHERE id = 2;

SELECT * FROM clientes WHERE id = 1;

DELETE FROM pedidos WHERE id = 1;

SELECT * FROM clientes WHERE id = 1;

