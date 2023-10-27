CREATE TRIGGER insere_cliente_audit
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Novo cliente inserido em ', NOW()));
END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER exclui_cliente_audit
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Tentativa de exclusão do cliente ID ', OLD.id, ' em ', NOW()));
END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER atualiza_cliente_audit
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF OLD.nome != NEW.nome THEN
        INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Nome do cliente ID ', NEW.id, ' alterado de "', OLD.nome, '" para "', NEW.nome, '" em ', NOW()));
    END IF;
END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER impede_nome_nulo_vazio
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido atualizar o nome para vazio ou NULL';
    END IF;
END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER atualiza_estoque_pedido
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    UPDATE Produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    IF (SELECT estoque FROM Produtos WHERE id = NEW.produto_id) < 5 THEN
        INSERT INTO Auditoria (mensagem) VALUES (CONCAT('Estoque do produto ID ', NEW.produto_id, ' ficou abaixo de 5 unidades em ', NOW()));
    END IF;
END;
