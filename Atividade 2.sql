-- Criar banco de dados
CREATE DATABASE hospedar;


-- Criação da tabela de Usuários
CREATE TABLE Usuario (
 id SERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 email VARCHAR(100) NOT NULL UNIQUE,
 senha VARCHAR(100) NOT NULL,
 data_nascimento DATE NOT NULL,
 tipo_usuario TEXT CHECK (tipo_usuario IN ('Anfitrião', 'Hóspede')) NOT NULL,
 telefone VARCHAR(15)
);

-- Criação da tabela de Propriedades
CREATE TABLE Propriedade (
 id SERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 endereco VARCHAR(255) NOT NULL,
 descricao TEXT,
 num_quartos INT NOT NULL,
 capacidade INT NOT NULL,
 preco_diaria DECIMAL(10, 2) NOT NULL,
 usuario_id INT NOT NULL,
 FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Criação da tabela de Reservas
CREATE TABLE Reserva (
 id SERIAL PRIMARY KEY,
 data_inicio DATE NOT NULL,
 data_termino DATE NOT NULL,
 status TEXT CHECK (status IN ('Pendente', 'Confirmada', 'Cancelada')) NOT NULL,
 propriedade_id INT NOT NULL,
 usuario_id INT NOT NULL,
 FOREIGN KEY (propriedade_id) REFERENCES Propriedade(id) ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Criação da tabela de Avaliações
CREATE TABLE Avaliacao (
 id SERIAL PRIMARY KEY,
 nota INT CHECK (nota BETWEEN 1 AND 5),
 comentario TEXT,
 usuario_id INT NOT NULL,
 propriedade_id INT NOT NULL,
 FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (propriedade_id) REFERENCES Propriedade(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Criação da tabela de Mensagens
CREATE TABLE Mensagem (
 id SERIAL PRIMARY KEY,
 data_hora TIMESTAMP NOT NULL,
 conteudo TEXT NOT NULL,
 remetente_id INT NOT NULL,
 destinatario_id INT NOT NULL,
 FOREIGN KEY (remetente_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (destinatario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Inserção de dados na tabela de Usuários
INSERT INTO Usuario (nome, email, senha, data_nascimento, tipo_usuario, telefone) VALUES
('Ana Silva', 'ana.silva@example.com', 'senha123', '1990-01-01', 'Anfitrião', '1111111111'),
('Bruno Souza', 'bruno.souza@example.com', 'senha123', '1985-02-14', 'Hóspede', '2222222222'),
('Carlos Oliveira', 'carlos.oliveira@example.com', 'senha123', '1978-03-23', 'Anfitrião', '3333333333'),
('Daniela Lima', 'daniela.lima@example.com', 'senha123', '1995-04-04', 'Hóspede', '4444444444'),
('Eduardo Santos', 'eduardo.santos@example.com', 'senha123', '1980-05-15', 'Anfitrião', '5555555555'),
('Fernanda Costa', 'fernanda.costa@example.com', 'senha123', '1992-06-30', 'Hóspede', '6666666666'),
('Gustavo Almeida', 'gustavo.almeida@example.com', 'senha123', '1987-07-21', 'Anfitrião', '7777777777'),
('Helena Rocha', 'helena.rocha@example.com', 'senha123', '1993-08-11', 'Hóspede', '8888888888'),
('Igor Ferreira', 'igor.ferreira@example.com', 'senha123', '1981-09-09', 'Anfitrião', '9999999999'),
('Juliana Mendes', 'juliana.mendes@example.com', 'senha123', '1989-10-10', 'Hóspede', '1010101010');

-- Inserção de dados na tabela de Propriedades
INSERT INTO Propriedade (nome, endereco, descricao, num_quartos, capacidade, preco_diaria, usuario_id) VALUES
('Casa de Praia', 'Rua A, 123, Praia', 'Casa confortável perto do mar', 3, 6, 500.00, 1),
('Apartamento Centro', 'Av. Central, 456, Centro', 'Apartamento moderno no centro da cidade', 2, 4, 300.00, 3),
('Sítio da Montanha', 'Estrada B, 789, Montanha', 'Sítio tranquilo com vista para a montanha', 5, 10, 800.00, 5),
('Chalé da Serra', 'Rua C, 101, Serra', 'Chalé aconchegante na serra', 2, 4, 350.00, 7),
('Flat da Cidade', 'Av. D, 202, Cidade', 'Flat bem localizado na cidade', 1, 2, 250.00, 9);

-- Inserção de dados na tabela de Reservas
INSERT INTO Reserva (data_inicio, data_termino, status, propriedade_id, usuario_id) VALUES
('2024-07-01', '2024-07-10', 'Confirmada', 1, 2),
('2024-07-15', '2024-07-20', 'Pendente', 2, 4),
('2024-08-01', '2024-08-05', 'Confirmada', 3, 6),
('2024-09-01', '2024-09-07', 'Cancelada', 4, 8),
('2024-10-10', '2024-10-15', 'Confirmada', 5, 10);

-- Inserção de dados na tabela de Avaliações
INSERT INTO Avaliacao (nota, comentario, usuario_id, propriedade_id) VALUES
(5, 'Excelente estadia!', 2, 1),
(4, 'Muito bom, recomendo!', 4, 2),
(3, 'Satisfatório, mas pode melhorar.', 6, 3),
(5, 'Lugar maravilhoso!', 8, 4),
(4, 'Boa experiência.', 10, 5);

-- Inserção de dados na tabela de Mensagens
INSERT INTO Mensagem (data_hora, conteudo, remetente_id, destinatario_id) VALUES
('2024-06-20 10:00:00', 'Olá, gostaria de mais informações sobre a casa de praia.', 2, 1),
('2024-06-21 11:00:00', 'Claro, o que você gostaria de saber?', 1, 2),
('2024-06-22 12:00:00', 'Qual a distância até a praia?', 2, 1),
('2024-06-23 13:00:00', 'Apenas 5 minutos a pé.', 1, 2),
('2024-06-24 14:00:00', 'Obrigado!', 2, 1);


-- 1. Inserir um novo usuário
CREATE OR REPLACE FUNCTION inserir_usuario(
    p_nome VARCHAR,
    p_email VARCHAR,
    p_senha VARCHAR,
    p_data_nascimento DATE,
    p_tipo_usuario VARCHAR,
    p_telefone VARCHAR
) RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Usuario WHERE email = p_email) THEN
        RAISE EXCEPTION 'E-mail já cadastrado';
    END IF;
    
    INSERT INTO Usuario (nome, email, senha, data_nascimento, tipo_usuario, telefone)
    VALUES (p_nome, p_email, p_senha, p_data_nascimento, p_tipo_usuario, p_telefone);
END;
$$ LANGUAGE plpgsql;

-- 2. Atualizar telefone de um usuário
CREATE OR REPLACE FUNCTION atualizar_telefone(p_id INT, p_telefone VARCHAR) RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id = p_id) THEN
        RAISE EXCEPTION 'Usuário não encontrado';
    END IF;
    
    UPDATE Usuario SET telefone = p_telefone WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- 3. Excluir uma propriedade pelo ID
CREATE OR REPLACE FUNCTION excluir_proprieScript para Criação das Tabelas:
CREATE DATABASE hospedar;
USE hospedar;
-- Criação da tabela de Usuários
CREATE TABLE Usuario (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 email VARCHAR(100) NOT NULL UNIQUE,
 senha VARCHAR(100) NOT NULL,
 data_nascimento DATE NOT NULL,
 tipo_usuario ENUM('Anfitrião', 'Hóspede') NOT NULL,
 telefone VARCHAR(15)
);
-- Criação da tabela de Propriedades
CREATE TABLE Propriedade (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 endereco VARCHAR(255) NOT NULL,
 descricao TEXT,
 num_quartos INT NOT NULL,
 capacidade INT NOT NULL,
 preco_diaria DECIMAL(10, 2) NOT NULL,
 usuario_id INT NOT NULL,
 FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON
DELETE CASCADE
);
-- Criação da tabela de Reservas
CREATE TABLE Reserva (
 id INT AUTO_INCREMENT PRIMARY KEY,
 data_inicio DATE NOT NULL,
 data_termino DATE NOT NULL,
 status ENUM('Pendente', 'Confirmada', 'Cancelada') NOT NULL,
 propriedade_id INT NOT NULL,
 usuario_id INT NOT NULL,
 FOREIGN KEY (propriedade_id) REFERENCES Propriedade(id) ON UPDATE
CASCADE ON DELETE CASCADE,
 FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON
DELETE CASCADE
);
-- Criação da tabela de Avaliações
CREATE TABLE Avaliacao (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nota INT CHECK(nota BETWEEN 1 AND 5),
 comentario TEXT,
 usuario_id INT NOT NULL,
 propriedade_id INT NOT NULL,
 FOREIGN KEY (usuario_id) REFERENCES Usuario(id) ON UPDATE CASCADE ON
DELETE CASCADE,
 FOREIGN KEY (propriedade_id) REFERENCES Propriedade(id) ON UPDATE
CASCADE ON DELETE CASCADE
);
-- Criação da tabela de Mensagens
CREATE TABLE Mensagem (
 id INT AUTO_INCREMENT PRIMARY KEY,
 data_hora DATETIME NOT NULL,
 conteudo TEXT NOT NULL,
 remetente_id INT NOT NULL,
 destinatario_id INT NOT NULL,
 FOREIGN KEY (remetente_id) REFERENCES Usuario(id) ON UPDATE CASCADE
ON DELETE CASCADE,
 FOREIGN KEY (destinatario_id) REFERENCES Usuario(id) ON UPDATE CASCADE
ON DELETE CASCADE
);
Script para Inserção de Dados:
-- Populando a tabela de Usuários
INSERT INTO Usuario (nome, email, senha, data_nascimento, tipo_usuario,
telefone) VALUES
('Ana Silva', 'ana.silva@example.com', 'senha123', '1990-01-01', 'Anfitrião',
'1111111111'),
('Bruno Souza', 'bruno.souza@example.com', 'senha123', '1985-02-14', 'Hóspede',
'2222222222'),
('Carlos Oliveira', 'carlos.oliveira@example.com', 'senha123', '1978-03-23',
'Anfitrião', '3333333333'),
('Daniela Lima', 'daniela.lima@example.com', 'senha123', '1995-04-04', 'Hóspede',
'4444444444'),
('Eduardo Santos', 'eduardo.santos@example.com', 'senha123', '1980-05-15',
'Anfitrião', '5555555555'),
('Fernanda Costa', 'fernanda.costa@example.com', 'senha123', '1992-06-30',
'Hóspede', '6666666666'),
('Gustavo Almeida', 'gustavo.almeida@example.com', 'senha123', '1987-07-21',
'Anfitrião', '7777777777'),
('Helena Rocha', 'helena.rocha@example.com', 'senha123', '1993-08-11',
'Hóspede', '8888888888'),
('Igor Ferreira', 'igor.ferreira@example.com', 'senha123', '1981-09-09', 'Anfitrião',
'9999999999'),
('Juliana Mendes', 'juliana.mendes@example.com', 'senha123', '1989-10-10',
'Hóspede', '1010101010');
-- Populando a tabela de Propriedades
INSERT INTO Propriedade (nome, endereco, descricao, num_quartos, capacidade,
preco_diaria, usuario_id) VALUES
('Casa de Praia', 'Rua A, 123, Praia', 'Casa confortável perto do mar', 3, 6, 500.00,
1),
('Apartamento Centro', 'Av. Central, 456, Centro', 'Apartamento moderno no centro
da cidade', 2, 4, 300.00, 3),
('Sítio da Montanha', 'Estrada B, 789, Montanha', 'Sítio tranquilo com vista para a
montanha', 5, 10, 800.00, 5),
('Chalé da Serra', 'Rua C, 101, Serra', 'Chalé aconchegante na serra', 2, 4, 350.00,
7),
('Flat da Cidade', 'Av. D, 202, Cidade', 'Flat bem localizado na cidade', 1, 2, 250.00,
9),
('Casa de Campo', 'Estrada E, 303, Campo', 'Casa espaçosa no campo', 4, 8,
600.00, 1),
('Apartamento Luxo', 'Rua F, 404, Bairro Nobre', 'Apartamento de luxo com todas as
comodidades', 3, 6, 1000.00, 3),
('Quarto Simples', 'Av. G, 505, Bairro Simples', 'Quarto simples para estadias
curtas', 1, 2, 150.00, 5),
('Pousada do Sol', 'Rua H, 606, Praia', 'Pousada charmosa perto da praia', 5, 10,
700.00, 7),
('Cabana do Lago', 'Estrada I, 707, Lago', 'Cabana rústica à beira do lago', 2, 4,
400.00, 9);
-- Populando a tabela de Reservas
INSERT INTO Reserva (data_inicio, data_termino, status, propriedade_id,
usuario_id) VALUES
('2024-07-01', '2024-07-10', 'Confirmada', 1, 2),
('2024-07-15', '2024-07-20', 'Pendente', 2, 4),
('2024-08-01', '2024-08-05', 'Confirmada', 3, 6),
('2024-09-01', '2024-09-07', 'Cancelada', 4, 8),
('2024-10-10', '2024-10-15', 'Confirmada', 5, 10),
('2024-07-05', '2024-07-12', 'Pendente', 6, 2),
('2024-07-20', '2024-07-25', 'Confirmada', 7, 4),
('2024-08-10', '2024-08-15', 'Cancelada', 8, 6),
('2024-09-05', '2024-09-10', 'Confirmada', 9, 8),
('2024-10-15', '2024-10-20', 'Pendente', 10, 10);
-- Populando a tabela de Avaliações
INSERT INTO Avaliacao (nota, comentario, usuario_id, propriedade_id) VALUES
(5, 'Excelente estadia!', 2, 1),
(4, 'Muito bom, recomendo!', 4, 2),
(3, 'Satisfatório, mas pode melhorar.', 6, 3),
(5, 'Lugar maravilhoso!', 8, 4),
(4, 'Boa experiência.', 10, 5),
(2, 'Não gostei muito.', 2, 6),
(5, 'Perfeito!', 4, 7),
(3, 'Foi ok.', 6, 8),
(4, 'Gostei bastante.', 8, 9),
(5, 'Fantástico!', 10, 10);
-- Populando a tabela de Mensagens
INSERT INTO Mensagem (data_hora, conteudo, remetente_id, destinatario_id)
VALUES
('2024-06-20 10:00:00', 'Olá, gostaria de mais informações sobre a casa de praia.',
2, 1),
('2024-06-21 11:00:00', 'Claro, o que você gostaria de saber?', 1, 2),
('2024-06-22 12:00:00', 'Qual a distância até a praia?', 2, 1),
('2024-06-23 13:00:00', 'Apenas 5 minutos a pé.', 1, 2),
('2024-06-24 14:00:00', 'Obrigado!', 2, 1),
('2024-06-25 15:00:00', 'De nada, estou à disposição.', 1, 2),
('2024-06-26 16:00:00', 'Olá, o apartamento no centro está disponível?', 4, 3),
('2024-06-27 17:00:00', 'Sim, está disponível nas datas que você solicitou.', 3, 4),
('2024-06-28 18:00:00', 'Perfeito, vou reservar agora.', 4, 3),
('2024-06-29 19:00:00', 'Ótimo, qualquer dúvida me avise.', 3, 4);
dade(p_id INT) RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Reserva WHERE propriedade_id = p_id AND status = 'Confirmada') THEN
        RAISE EXCEPTION 'Não é possível excluir a propriedade, pois há reservas confirmadas';
    END IF;
    
    DELETE FROM Propriedade WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Listar reservas de um usuário
CREATE OR REPLACE FUNCTION listar_reservas_usuario(p_usuario_id INT) RETURNS TABLE (
    id INT, data_inicio DATE, data_termino DATE, status VARCHAR, propriedade_id INT
) AS $$
BEGIN
    RETURN QUERY SELECT id, data_inicio, data_termino, status, propriedade_id
    FROM Reserva WHERE usuario_id = p_usuario_id ORDER BY data_inicio;
END;
$$ LANGUAGE plpgsql;

-- 5. Registrar nova reserva
CREATE OR REPLACE FUNCTION registrar_reserva(
    p_data_inicio DATE,
    p_data_termino DATE,
    p_propriedade_id INT,
    p_usuario_id INT
) RETURNS VOID AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reserva 
        WHERE usuario_id = p_usuario_id 
        AND ((p_data_inicio BETWEEN data_inicio AND data_termino) 
        OR (p_data_termino BETWEEN data_inicio AND data_termino))
    ) THEN
        RAISE EXCEPTION 'O usuário já possui uma reserva nesse período';
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM Reserva 
        WHERE propriedade_id = p_propriedade_id 
        AND ((p_data_inicio BETWEEN data_inicio AND data_termino) 
        OR (p_data_termino BETWEEN data_inicio AND data_termino))
    ) THEN
        RAISE EXCEPTION 'A propriedade já está reservada nesse período';
    END IF;
    
    INSERT INTO Reserva (data_inicio, data_termino, status, propriedade_id, usuario_id)
    VALUES (p_data_inicio, p_data_termino, 'Pendente', p_propriedade_id, p_usuario_id);
END;
$$ LANGUAGE plpgsql;

-- 6. Contar avaliações de uma propriedade
CREATE OR REPLACE FUNCTION contar_avaliacoes(p_propriedade_id INT) RETURNS INT AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total FROM Avaliacao WHERE propriedade_id = p_propriedade_id;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- 7. Listar mensagens entre dois usuários
CREATE OR REPLACE FUNCTION listar_mensagens(p_usuario1 INT, p_usuario2 INT) RETURNS TABLE (
    id INT, data_hora TIMESTAMP, conteudo TEXT, remetente_id INT, destinatario_id INT
) AS $$
BEGIN
    RETURN QUERY 
    SELECT id, data_hora, conteudo, remetente_id, destinatario_id 
    FROM Mensagem 
    WHERE (remetente_id = p_usuario1 AND destinatario_id = p_usuario2)
       OR (remetente_id = p_usuario2 AND destinatario_id = p_usuario1)
    ORDER BY data_hora;
END;
$$ LANGUAGE plpgsql;

-- 8. Atualizar status de uma reserva
CREATE OR REPLACE FUNCTION atualizar_status_reserva(p_id INT, p_status VARCHAR) RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Reserva WHERE id = p_id AND status = 'Finalizada') THEN
        RAISE EXCEPTION 'Não é possível alterar uma reserva finalizada';
    END IF;
    
    UPDATE Reserva SET status = p_status WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- 9. Calcular receita total de um anfitrião
CREATE OR REPLACE FUNCTION calcular_receita_anfitriao(p_anfitriao_id INT) RETURNS DECIMAL(10,2) AS $$
DECLARE
    receita_total DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(p.preco_diaria * (r.data_termino - r.data_inicio)), 0)
    INTO receita_total
    FROM Reserva r
    JOIN Propriedade p ON r.propriedade_id = p.id
    WHERE p.usuario_id = p_anfitriao_id AND r.status = 'Confirmada';
    
    RETURN receita_total;
END;
$$ LANGUAGE plpgsql;

-- 10. Calcular média de avaliações de uma propriedade
CREATE OR REPLACE FUNCTION calcular_media_avaliacoes(p_propriedade_id INT) RETURNS DECIMAL(3,2) AS $$
DECLARE
    media_avaliacoes DECIMAL(3,2);
BEGIN
    SELECT AVG(nota)::DECIMAL(3,2) INTO media_avaliacoes FROM Avaliacao WHERE propriedade_id = p_propriedade_id;
    RETURN media_avaliacoes;
END;
$$ LANGUAGE plpgsql;
