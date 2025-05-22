-- Script criação do esquema Biblioteca.
--> criação do esquema

CREATE SCHEMA biblioteca;
SET search_path = biblioteca;


--> Criação da tabela Livros
CREATE TABLE livros (
 id_livro SERIAL PRIMARY KEY,
 titulo VARCHAR(255) NOT NULL,
 autor VARCHAR(255) NOT NULL,
 ano_publicacao INT CHECK (ano_publicacao > 0),
 disponivel BOOLEAN DEFAULT TRUE -- TRUE significa que o livro está disponível
);


--> Criação da tabela Membros
CREATE TABLE membros (
 id_membro SERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 email VARCHAR(100) UNIQUE NOT NULL,
 data_cadastro DATE NOT NULL DEFAULT CURRENT_DATE
);


--> Criação da tabela Empréstimos
CREATE TABLE emprestimos (
 id_emprestimo SERIAL PRIMARY KEY,
 id_livro INT NOT NULL REFERENCES biblioteca.livros(id_livro) ON DELETE
CASCADE,
 id_membro INT NOT NULL REFERENCES biblioteca.membros(id_membro) ON
DELETE CASCADE,
 data_emprestimo DATE NOT NULL DEFAULT CURRENT_DATE,
 data_devolucao DATE NULL, -- NULL significa que o livro ainda não foi devolvido
 status VARCHAR(20) CHECK (status IN ('Em aberto', 'Finalizado')) NOT NULL
DEFAULT 'Em aberto'
);


--> Popular tabelas
INSERT INTO livros (titulo, autor, ano_publicacao, disponivel) VALUES
('Dom Quixote', 'Miguel de Cervantes', 1605, FALSE), -- Emprestado
('O Pequeno Príncipe', 'Antoine de Saint-Exupéry', 1943, FALSE), -- Emprestado
('Hamlet', 'William Shakespeare', 1603, FALSE), -- Emprestado
('Cem Anos de Solidão', 'Gabriel Garcia Márquez', 1967, FALSE), -- Emprestado
('Orgulho e Preconceito', 'Jane Austen', 1813, TRUE), -- Devolvido
('1984', 'George Orwell', 1949, TRUE), -- Devolvido
('O Senhor dos Anéis', 'J.R.R. Tolkien', 1954, TRUE), -- Devolvido
('A Divina Comédia', 'Dante Alighieri', 1320, TRUE); -- Devolvido


INSERT INTO membros (nome, email, data_cadastro) VALUES
('Ana Silva', 'ana.silva@example.com', '2022-01-10'),
('Bruno Gomes', 'bruno.gomes@example.com', '2022-02-15'),
('Carlos Eduardo', 'carlos.eduardo@example.com', '2022-03-20'),
('Daniela Rocha', 'daniela.rocha@example.com', '2022-05-05'),
('Eduardo Lima', 'eduardo.lima@example.com', '2022-06-10'),
('Fernanda Martins', 'fernanda.martins@example.com', '2022-07-15'),
('Gustavo Henrique', 'gustavo.henrique@example.com', '2022-08-20'),
('Helena Souza', 'helena.souza@example.com', '2022-09-25');


INSERT INTO biblioteca.emprestimos (id_livro, id_membro, data_emprestimo,
data_devolucao, status) VALUES
(1, 1, '2022-04-01', NULL, 'Em aberto'), -- Dom Quixote (Emprestado)
(2, 2, '2022-04-03', '2022-04-10', 'Finalizado'), -- O Pequeno Príncipe (Devolvido)
(3, 3, '2022-04-05', NULL, 'Em aberto'), -- Hamlet (Emprestado)
(4, 4, '2022-10-01', NULL, 'Em aberto'), -- Cem Anos de Solidão (Emprestado)
(5, 5, '2022-10-03', '2022-10-17', 'Finalizado'), -- Orgulho e Preconceito (Devolvido)
(2, 3, '2022-10-06', NULL, 'Em aberto'), -- O Pequeno Príncipe (Emprestado novamente)
(1, 2, '2022-10-08', '2022-10-15', 'Finalizado'), -- Dom Quixote (Devolvidoanteriormente)
(3, 1, '2022-10-10', NULL, 'Em aberto'), -- Hamlet (Emprestado novamente)
(3, 2, '2022-11-01', NULL, 'Em aberto'), -- Hamlet (Emprestado novamente)
(2, 3, '2022-11-03', NULL, 'Em aberto'), -- O Pequeno Príncipe (Emprestado novamente)
(1, 4, '2022-11-05', NULL, 'Em aberto'), -- Dom Quixote (Emprestado novamente)
(5, 1, '2022-11-07', '2022-11-21', 'Finalizado'), -- Orgulho e Preconceito (Devolvido)
(4, 5, '2022-11-09', '2022-11-23', 'Finalizado'), -- Cem Anos de Solidão (Devolvido)
(2, 1, '2022-11-12', NULL, 'Em aberto'), -- O Pequeno Príncipe (Emprestado novamente)
(3, 4, '2022-11-14', '2022-11-28', 'Finalizado'), -- Hamlet (Devolvido)
(1, 3, '2022-11-16', NULL, 'Em aberto'), -- Dom Quixote (Emprestado novamente)
(5, 2, '2022-11-18', '2022-11-25', 'Finalizado'), -- Orgulho e Preconceito (Devolvido)
(4, 1, '2022-11-20', '2022-12-04', 'Finalizado'); -- Cem Anos de Solidão (Devolvido)



-------------------ATIVIDADE PRATICA----------------------------------------------

-- A) Trigger de Atualização de Disponibilidade

CREATE OR REPLACE FUNCTION atualiza_disponibilidade()
RETURNS TRIGGER AS $$
BEGIN

IF NEW.status = 'Em aberto' THEN
UPDATE livro
SET disponivel = FALSE
WHERE id = NEW.livro_id;
	END IF;
	
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_atualizar_disponibilidade_livro
AFTER INSERT ON emprestimos
FOR EACH ROW
EXECUTE FUNCTION atualiza_disponibilidade();


-- B) Trigger de Devolução de Livro

CREATE OR REPLACE FUNCTION atualiza_devolucao()
RETURNS TRIGGER AS $$
BEGIN

	IF NEW.data_devolucao is NOT NULL THEN 
	UPDATE emprestimos
	SET status = 'Finalizado'
	WHERE id = NEW.id_emprestimo;
	
	UPDATE livros
	SET disponivel = 'TRUE'
	WHERE id = NEW.id_livros;
	
	END IF;
	
	RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;
	
	 CREATE TRIGGER trigger_atualiza_devolucao
	 AFTER INSERT ON emprestimos
	 FOR EACH ROW
	 EXECUTE FUNCTION atualiza_devolucao();
	
-- C) Trigger de Auditoria de Empréstimos

CREATE OR REPLACE FUNCTION registrar_auditoria_emprestimos()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria_emprestimos (id_emprestimo, id_livro, id_membro, data_emprestimo, acao)
    VALUES (NEW.id, NEW.id_livro, NEW.id_membro, NEW.data_emprestimo, 'Empréstimo Realizado');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criando a trigger para chamar a função após um novo empréstimo
CREATE TRIGGER trigger_auditoria_emprestimos
AFTER INSERT ON emprestimos
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_emprestimos();



-- D) Trigger de Verificação de Disponibilidade

CREATE OR REPLACE FUNCTION verificar_disponibilidade()
RETURNS TRIGGER AS $$
BEGIN

	IF NEW.disponivel IS FALSE THEN
	RAISE NOTICE 'O livro não está disponível para empréstimo no
momento.';
	
	END IF;
	RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;


	CREATE TRIGGER trigger_verificar_disponibilidade
	BEFORE INSERT ON emprestimos
	FOR EACH ROW
	EXECUTE FUNCTION verificar_disponibilidade();

-- E) Trigger de Limite de Empréstimos

CREATE OR REPLACE FUNCTION limite_emprestimo()
RETURNS TRIGGER AS $$
DECLARE
	contador INT :=0;
BEGIN 
	SELECT COUNT(*) INTO contador
	FROM emprestimos
	WHERE id_membros = NEW.id_membros AND status = 'Em aberto';
	
	IF contador >= 5 THEN 
	RAISE EXCEPTION 'O membro % já atingiu o limite de 5 empréstimos ativos.', NEW.id_membro;
	
	END IF;
	RETURN NEW;
	END
	$$ LANGUAGE plpgsql;
	
	CREATE TRIGGER trigger_limite_emprestimo
	BEFORE INSERT ON emprestimos
	FOR EACH ROW
	EXECUTE FUNCTION limite_emprestimo();

-- F) Trigger de Atualização de Livros

CREATE OR REPLACE FUNCTION registrar_historico_livros()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico_livros (id_livro, titulo_antigo, autor_antigo, ano_publicacao_antigo)
    VALUES (OLD.id_livro, OLD.titulo, OLD.autor, OLD.ano_publicacao);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criando a trigger para chamar a função após atualização na tabela livros
CREATE TRIGGER trigger_historico_livros
BEFORE UPDATE ON livros
FOR EACH ROW
EXECUTE FUNCTION registrar_historico_livros();

-- G) Trigger de Exclusão de Membro

CREATE OR REPLACE FUNCTION vertificacao_Exclusao_membros()
RETURNS TRIGGER AS $$
DECLARE 
	qtd_emprestimos INT;
BEGIN 

SELECT COUNT(*) INTO qtd_emprestimos
FROM emprestimos
WHERE id_livro = OLD.id AND status = 'Em aberto';

IF qtd_emprestimos > 0 THEN
	RAISE EXCEPTION 'Não é possível excluir o livro %, pois ele está atualmente emprestado.', OLD.id;
END IF;

RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_verificar_emprestimos
BEFORE DELETE ON membros
FOR EACH ROW
EXECUTE FUNCTION vertificacao_Exclusao_membros();

-- H) Trigger de Auditoria para Inserção, Atualização e Deleção de Livros

CREATE OR REPLACE FUNCTION registrar_auditoria_livros()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria_livros (operacao, titulo, autor, ano_publicacao)
        VALUES ('I', NEW.titulo, NEW.autor, NEW.ano_publicacao);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria_livros (operacao, titulo, autor, ano_publicacao)
        VALUES ('U', OLD.titulo, OLD.autor, OLD.ano_publicacao);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria_livros (operacao, titulo, autor, ano_publicacao)
        VALUES ('D', OLD.titulo, OLD.autor, OLD.ano_publicacao);
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Criando a trigger para capturar inserções, atualizações e deleções na tabela livros
CREATE TRIGGER trigger_auditoria_livros
AFTER INSERT OR UPDATE OR DELETE ON livros
FOR EACH ROW
EXECUTE FUNCTION registrar_auditoria_livros();

-- I) Trigger para Verificar a Exclusão de Livros

CREATE OR REPLACE FUNCTION vertificacao_Exclusao()
RETURNS TRIGGER AS $$
DECLARE 
	qtd_emprestimos INT;
BEGIN 

SELECT COUNT(*) INTO qtd_emprestimos
FROM emprestimos
WHERE id_livro = OLD.id AND status = 'Em aberto';

IF qtd_emprestimos > 0 THEN
	RAISE EXCEPTION 'Não é possível excluir o livro %, pois ele está atualmente emprestado.', OLD.id;
END IF;

RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_verificar_emprestimos
BEFORE DELETE ON livros
FOR EACH ROW
EXECUTE FUNCTION vertificacao_Exclusao();
