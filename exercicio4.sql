CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE clientes_deletados_log (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data_remocao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_soft_delete_cliente()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar na tabela de auditoria
    INSERT INTO clientes_deletados_log (cliente_id, nome, email)
    VALUES (OLD.id, OLD.nome, OLD.email);

    -- Desativar o cliente fisicamente
    UPDATE clientes SET ativo = FALSE WHERE id = OLD.id;

    -- Retornar NULL cancela a instrução DELETE original!
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_soft_delete_cliente
BEFORE DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION fn_soft_delete_cliente();

