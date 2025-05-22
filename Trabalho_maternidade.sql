CREATE SCHEMA maternidade;
SET search_path = maternidade;

CREATE TABLE cidade (
 id_cidade SERIAL PRIMARY KEY,
 nome VARCHAR(100) NOT NULL,
 uf CHAR(2) NOT NULL
);

CREATE TABLE mae (
 id_mae SERIAL PRIMARY KEY,
 id_cidade INT NOT NULL,
 nome VARCHAR(100) NOT NULL,
 celular VARCHAR(15) NOT NULL,
 FOREIGN KEY (id_cidade) REFERENCES maternidade.cidade(id_cidade) ON DELETE CASCADE
);

CREATE TABLE medico (
 id_medico SERIAL PRIMARY KEY,
 id_cidade INT NOT NULL,
 crm VARCHAR(10) NOT NULL,
 nome VARCHAR(100) NOT NULL,
 celular VARCHAR(15) NOT NULL,
 salario DECIMAL(10,2) NOT NULL,
 status SMALLINT NOT NULL,
 FOREIGN KEY (id_cidade) REFERENCES maternidade.cidade(id_cidade) ON DELETE CASCADE
);

CREATE TABLE nascimento (
 id_nascimento SERIAL PRIMARY KEY,
 id_mae INT NOT NULL,
 id_medico INT NOT NULL,
 nome VARCHAR(100),
 data_nascimento DATE,
 peso DECIMAL(5,3),
 altura SMALLINT,
 FOREIGN KEY (id_mae) REFERENCES maternidade.mae(id_mae) ON DELETE CASCADE,
 FOREIGN KEY (id_medico) REFERENCES maternidade.medico(id_medico) ON DELETE CASCADE
);

CREATE TABLE agendamento (
 id_agendamento SERIAL PRIMARY KEY,
 id_nascimento INT NOT NULL,
 inicio TIMESTAMP,
 fim TIMESTAMP,
 FOREIGN KEY (id_nascimento) REFERENCES maternidade.nascimento(id_nascimento) ON DELETE CASCADE
);



INSERT INTO maternidade.cidade (nome, uf) VALUES 
('Florianópolis', 'SC'),
('Itajaí', 'SC'),
('Balneário Camboriú', 'SC'),
('Joinville', 'SC'),
('Itapema', 'SC');


INSERT INTO maternidade.mae (id_cidade, nome, celular) VALUES 
(1, 'Adriana', '47963258741'),
(2, 'Letícia', '47999990002'),
(3, 'Elsa', '48999990003'),
(4, 'Denise', '48999431258'),
(5, 'Débora', '47978570032');


INSERT INTO maternidade.medico (id_cidade, crm, nome, celular, salario, status) VALUES 
(1, 'SC12345', 'João', '48988880001', 12000.50, 1),
(2, 'SC23456', 'Maria', '48988880002', 13500.75, 1),
(3, 'SC34567', 'Carlo', '48988880003', 11000.00, 1),
(4, 'SC45678', 'Fernanda', '48988880004', 12500.30, 1),
(5, 'SC56789', 'Pedro', '48988880005', 14000.90, 1);


INSERT INTO maternidade.nascimento (id_mae, id_medico, nome, data_nascimento, peso, altura) VALUES 
(1, 1, 'Daniel', '2025-03-01', 3.200, 50),
(2, 2, 'Maria', '2025-03-30', 2.900, 48),
(3, 3, 'Gabriel', '2025-03-21', 3.500, 52),
(4, 4, 'Jhonatan', '2025-02-15', 3.100, 49),
(5, 5, 'Rafael', '2025-01-20', 2.800, 47);


INSERT INTO maternidade.agendamento (id_nascimento, inicio, fim) VALUES 
(1, '2025-03-01 08:00:00', '2025-03-01 09:00:00'),
(2, '2025-03-05 10:00:00', '2025-03-30 11:00:00'),
(3, '2025-03-10 14:00:00', '2025-03-21 15:00:00'),
(4, '2025-03-15 16:00:00', '2025-02-15 17:00:00'),
(5, '2025-03-20 18:00:00', '2025-01-20 19:00:00');




---------------------------  4 QUESTÃO ------------------------------------------

---------- 1)

CREATE OR REPLACE FUNCTION validar_medico_ativo()
RETURNS TRIGGER 
AS $$
DECLARE 
	medico_status INT;
BEGIN 

	-- Botar status do medico para a variavel medico_status
	SELECT status INTO medico_status FROM medico WHERE id_medico = NEW.id_medico;

	-- Ver se o medico esta com status ativo
	IF medico_status = 0 THEN
	RAISE EXCEPTION 'Médico inativo';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_medico_ativo
BEFORE INSERT ON nascimento
FOR EACH ROW 
EXECUTE FUNCTION validar_medico_ativo();

-------- DROP (CASO NECESSARIO) ------------------

DROP FUNCTION validar_medico_ativo() CASCADE;

DROP TRIGGER IF EXISTS trigger_validar_medico_ativo ON nascimento;

------------------------- TESTE -----------------------------------

INSERT INTO medico (id_cidade, crm, nome, celular, salario, status)
VALUES (1, '654321', 'Dra. Maria', '988888888', 12000.00, 0);

INSERT INTO nascimento (id_mae, id_medico, nome, data_nascimento, peso, altura)
VALUES (1, 6, 'Bebê Exemplo', '2025-04-01', 3.2, 48);

---------- 2)

CREATE OR REPLACE FUNCTION validar_campos_nascimento()
RETURNS TRIGGER 
AS $$
BEGIN

	-- Verificar se o nome está null
	IF NEW.nome IS NULL THEN
        RAISE EXCEPTION 'Erro: O campo nome não pode ser nulo.';
    END IF;

	-- Verificar se o data_nascimento está null
	IF NEW.data_nascimento IS NULL THEN
        RAISE EXCEPTION 'Erro: O campo data_nascimento não pode ser nulo.';
    END IF;

	-- Verificar se o peso está null
	IF NEW.peso IS NULL THEN
        RAISE EXCEPTION 'Erro: O campo peso não pode ser nulo.';
    END IF;

	-- Verificar se o altura está null
	IF NEW.altura IS NULL THEN
        RAISE EXCEPTION 'Erro: O campo altura não pode ser nulo.';
    END IF;
	RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_campos_nascimento
BEFORE UPDATE ON nascimento
FOR EACH ROW
EXECUTE FUNCTION validar_campos_nascimento();

-------- DROP (CASO NECESSARIO) ------------------

DROP FUNCTION validar_campos_nascimento() CASCADE;

DROP TRIGGER IF EXISTS trigger_validar_campos_nascimento ON nascimento;

------------------------- TESTE -----------------------------------
UPDATE nascimento
SET nome = NULL
WHERE id_nascimento = 1;

UPDATE nascimento
SET data_nascimento = NULL
WHERE id_nascimento = 1;

UPDATE nascimento
SET peso = NULL
WHERE id_nascimento = 1;

UPDATE nascimento
SET altura = NULL
WHERE id_nascimento = 1;


---------- 3)

CREATE OR REPLACE FUNCTION validacao_agendamentos()
RETURNS TRIGGER
AS $$
DECLARE
    dia_semana INT;
BEGIN
 -- Obtém o dia da semana (0 = domingo, 1 = segunda, ..., 6 = sábado)
    dia_semana := EXTRACT(DOW FROM NEW.inicio);

    -- Verifica se é sábado (6) ou domingo (0)
    IF dia_semana = 0 OR dia_semana = 6 THEN
        RAISE EXCEPTION 'Erro: O hospital não realiza agendamentos aos sábados e domingos.';
    END IF;

    -- Verifica se o horário de início está dentro do expediente permitido
    IF NOT (
        (NEW.inicio::TIME BETWEEN '08:00' AND '12:00') OR
        (NEW.inicio::TIME BETWEEN '13:30' AND '17:30')
    ) THEN
        RAISE EXCEPTION 'Erro: O agendamento deve começar dentro do horário de expediente (08:00-12:00 e 13:30-17:30).';
    END IF;

    -- Verifica se o horário de término está dentro do expediente permitido
    IF NOT (
        (NEW.fim::TIME BETWEEN '08:00' AND '12:00') OR
        (NEW.fim::TIME BETWEEN '13:30' AND '17:30')
    ) THEN
        RAISE EXCEPTION 'Erro: O agendamento não pode ultrapassar o horário do expediente.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_validacao_agendamentos
BEFORE INSERT OR UPDATE ON agendamento
FOR EACH ROW
EXECUTE FUNCTION validacao_agendamentos();


-------- DROP (CASO NECESSARIO) ------------------

DROP FUNCTION validar_campos_nascimento() CASCADE;

DROP TRIGGER IF EXISTS trigger_validar_campos_nascimento ON nascimento;

------------------------- TESTE -----------------------------------

INSERT INTO agendamento (id_nascimento, inicio, fim)
VALUES (1, '2025-04-02 09:00:00', '2025-04-02 10:00:00');

INSERT INTO agendamento (id_nascimento, inicio, fim)
VALUES (1, '2025-04-06 10:00:00', '2025-04-06 11:00:00');

INSERT INTO agendamento (id_nascimento, inicio, fim)
VALUES (1, '2025-04-02 07:00:00', '2025-04-02 08:30:00');

INSERT INTO agendamento (id_nascimento, inicio, fim)
VALUES (1, '2025-04-02 11:50:00', '2025-04-02 12:10:00');




