CREATE TABLE pedido (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_nome VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL
);

CREATE OR REPLACE FUNCTION fn_recalcula_total_pedido()
RETURNS TRIGGER AS $$
DECLARE
    v_pedido_id INT;
    v_total NUMERIC(10,2);
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_pedido_id := OLD.pedido_id;
    ELSE
        v_pedido_id := NEW.pedido_id;
    END IF;

    SELECT COALESCE(SUM(quantidade * preco_unitario), 0.00)
    INTO v_total
    FROM itens_pedido
    WHERE pedido_id = v_pedido_id;

    UPDATE pedidos
    SET valor_total = v_total
    WHERE id = v_pedido_id;

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualiza_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON itens_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_recalcula_total_pedido();

select * FROM
pedido

INSERT INTO pedido (cliente)
VALUES ('Fernanda Morais');

select * from 
pedido
