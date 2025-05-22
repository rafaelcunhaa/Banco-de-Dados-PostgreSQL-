-- PARA ESTA ATIVIDADE, EFETUE AS SEGUINTES ETAPAS:
--	1. EFETUE A CRIAÇÃO DAS TABELAS, LINHAS 6 A 64
-- 	2. EFETUE A INSERÇÃO DOS REGISTROS, LINAS 67 A 115
-- 	3. EFETUE A CRIAÇÃO DE FUNÇÕES PARA CADA UM DOS EXERCICIOS A PARTIR DA LINHA 118

/* clinica veterinaria */
SELECT schema_name FROM information_schema.schemata;
SHOW search_path;
CREATE SCHEMA clinica_vet;
SET search_path = clinica_vet;

CREATE TABLE Endereco (
    cod serial PRIMARY KEY,
    logradouro varchar(100),
    numero integer,
    complemento varchar(50),
    cep varchar(12),
    cidade varchar(50),
    uf varchar(2)
);

CREATE TABLE Responsavel (
    cod serial PRIMARY KEY,
    nome varchar(100) NOT NULL,
    cpf varchar(12) NOT NULL,
    fone varchar(50) NOT NULL,
    email varchar(100) NOT NULL,
    cod_end integer,
    UNIQUE (cpf, email),
    FOREIGN KEY (cod_end) REFERENCES Endereco (cod) 
);

CREATE TABLE Pet (
    cod serial PRIMARY KEY,
    nome varchar(100),
    raca varchar(50),
    peso decimal(5,2),
    data_nasc date,
    cod_resp integer,
    FOREIGN KEY (cod_resp) REFERENCES Responsavel (cod) 
);

CREATE TABLE Veterinario (
    cod serial PRIMARY KEY,
    nome varchar(100),
    crmv numeric(10),
    especialidade varchar(50),
    fone varchar(50),
    email varchar(100),
    cod_end integer,
	FOREIGN KEY (cod_end) REFERENCES Endereco (cod) 
);

CREATE TABLE Consulta (
    cod serial PRIMARY KEY,
    dt date,
    horario time,
    cod_vet integer,
    cod_pet integer,
    FOREIGN KEY (cod_vet) REFERENCES Veterinario (cod), 
    FOREIGN KEY (cod_pet) REFERENCES Pet (cod) 
);

-- inserindo enderecos
INSERT INTO endereco(logradouro,numero,complemento,cep,cidade,uf) 
	VALUES 	('Rua Tenente-Coronel Cardoso', '501', 'ap 1001','28035042','Campos dos Goytacazes','RJ'),
			('Rua Serra de Bragança', '980', null,'03318000','São Paulo','SP'),
			('Rua Barão de Vitória', '50', 'loja A','09961660','Diadema','SP'),
			('Rua Pereira Estéfano', '700', 'ap 202 a','04144070','São Paulo','SP'),
			('Avenida Afonso Pena', '60', null,'30130005','São Paulo','SP'),
			('Rua das Fiandeiras', '123', 'Sala 501','04545005','São Paulo','SP'),
			('Rua Cristiano Olsen', '2549', 'ap 506','16015244','Araçatuba','SP'),
			('Avenida Desembargador Moreira', '908', 'Ap 405','60170001','Fortaleza','CE'),
			('Avenida Almirante Maximiano Fonseca', '362', null,'88113350','Rio Grande','RS'),
			('Rua Arlindo Nogueira', '219', 'ap 104','64000290','Teresina','PI');

-- inserindo responsaveis
INSERT INTO responsavel(nome,cpf,email,fone,cod_end) 
	VALUES 	('Márcia Luna Duarte', '1111111111', 'marcia.luna.duarte@deere.com','(63) 2980-8765',1),
			('Benício Meyer Azevedo','23101771056', 'beniciomeyer@gmail.com.br','(63) 99931-8289',2),
			('Ana Beatriz Albergaria Bochimpani Trindade','61426227400','anabeatriz@ohms.com.br', '(87) 2743-5198',3),
			('Thiago Edson das Neves','31716341124','thiago_edson_dasneves@paulistadovale.org.br','(85) 3635-5560',4),
			('Luna Cecília Alves','79107398','luna_alves@orthoi.com.br','(67) 2738-7166',5);

-- inserindo veterinarios
INSERT INTO veterinario(nome,crmv,especialidade,email,fone,cod_end) 
	VALUES 	('Renan Bruno Diego Oliveira','35062','clinico geral','renanbrunooliveira@edu.uniso.br','(67) 99203-9967',6),
			('Clara Bárbara da Cruz','64121','dermatologista','clarabarbaradacruz@band.com.br','(63) 3973-7873',7),
			('Heloise Cristiane Emilly Moreira','80079','clinico geral','heloisemoreira@igoralcantara.com.br','(69) 2799-7715',8),
			('Laís Elaine Catarina Costa','62025','animais selvagens','lais-costa84@campanati.com.br','(79) 98607-4656',9),
			('Juliana Andrea Cardoso','00491','dermatologista','juliana_cardoso@br.ibn.com','(87) 98439-9604',10);

-- inserindo animais
INSERT INTO pet(cod_resp,nome,peso,raca,data_nasc) 
	VALUES 	(1, 'Mike', 12, 'pincher', '2010-12-20'),
			(1, 'Nike', 20, 'pincher', '2010-12-20'),
			(2, 'Bombom', 10, 'shitzu', '2022-07-15'),
 			(3, 'Niro', 70, 'pastor alemao', '2018-10-12'),
			(4, 'Milorde', 5, 'doberman', '2019-11-16'),
 			(4, 'Laide', 4, 'coker spaniel','2018-02-27'),
 			(4, 'Lorde', 3, 'dogue alemão', '2019-05-15'),
			(5, 'Joe', 50, 'indefinido', '2020-01-01'),
			(5, 'Felicia', 5, 'indefinido', '2017-06-07');

-- inserindo consultas
INSERT INTO consulta(cod_pet, cod_vet, horario, dt) 
	VALUES 	(11,1,'14:30','2023-10-05'),
			(4,1,'15:00','2023-10-05'),
			(5,5,'16:30','2023-10-15'),
			(3,4,'14:30','2023-10-12'),
			(11,3,'18:00','2023-10-17'),
			(5,3,'14:10','2023-10-20'),
			(5,3,'10:30','2023-10-28');
			
			
-- EXERCÍCIOS:

-- 1. Crie uma função que insira um novo registro na tabela Endereco e 
--   retorne o código do endereço inserido.
-- Obs.: RETURNING cod; no final de um select retorna o cod criado (auto gerado).

SELECT *
FROM endereco

DELETE 
FROM endereco
WHERE cod = 11

CREATE OR REPLACE FUNCTION funcaoNova(logradouro_p varchar(100), numero_p int,  complemento_p varchar, cep_p varchar, cidade_p varchar, uf_p varchar)
RETURNS INTEGER AS 
$$

INSERT INTO Endereco(logradouro, numero, complemento, cep, cidade, uf) 
values (logradouro_p, numero_p, complemento_p, cep_p, cidade_p, uf_p) RETURNING cod,logradouro,numero,complemento, cep, cidade, uf ;

$$
LANGUAGE SQL;


select funcaoNova('Rua Cristiane Nascimento', 666, 'Apto 102', '88311152', 'Itapema', 'SC');


-- 2. Crie um procedimento que atualize o email de um responsável com base no seu código.

SELECT *
FROM responsavel

CREATE OR REPLACE FUNCTION emailNovo (cod_p int,email_p varchar(50))
RETURNS VARCHAR AS
$$
UPDATE Responsavel
SET email = email_p
WHERE cod = cod_p
RETURNING cod_p;

$$
LANGUAGE SQL;

SELECT emailNovo( 5 ,'sessssssssssssssssss@gmail.com');

DROP FUNCTION emailNovo (email_p varchar(50));


-- 3. Faça um procedumento para excluir um responsável. 
--	  Excluir seus pets e endereços. Sem a utilização do CASCADE na definição da tabela.

SELECT * FROM Consulta
SELECT * FROM Responsavel
SELECT * FROM Pet
SELECT * FROM endereco

UPDATE 

CREATE OR REPLACE PROCEDURE deletar(cod_p INT)AS
$$

DELETE FROM Consulta
WHERE cod_pet IN (SELECT cod FROM Pet WHERE cod_resp = cod_p);

DELETE FROM Pet
WHERE cod_resp = cod_p;

DELETE FROM endereco 
WHERE cod IN (SELECT cod_end FROM Responsavel WHERE cod = cod_p );

DELETE FROM Responsavel
WHERE cod = cod_p;

$$
LANGUAGE SQL;

CALL deletar(4);

DROP PROCEDURE deletar(cod_p INT);

-- 4. Crie uma função que liste todas as consultas agendadas em um determinado periodo (entre duas datas)
--   Deve retornar uma tabela com os campos data da consulta, nome do responsavel,
--   nome do pet, telefone do responsavel e nome do veterinario.

CREATE OR REPLACE FUNCTION listarConsultasPeriodo(dt_ini DATE, dt_fim DATE)
RETURNS TABLE(
    data_consulta DATE,
    nome_responsavel VARCHAR(100),
    nome_pet VARCHAR(100),
    fone_responsavel VARCHAR(50),
    nome_veterinario VARCHAR(100)
) 
LANGUAGE SQL
AS 
$$
BEGIN
    RETURN QUERY
    SELECT 
        c.dt AS data_consulta,
        r.nome AS nome_responsavel,
        p.nome AS nome_pet,
        r.fone AS fone_responsavel,
        v.nome AS nome_veterinario
    FROM Consulta c
    JOIN Pet p ON c.cod_pet = p.cod
    JOIN Responsavel r ON p.cod_resp = r.cod
    JOIN Veterinario v ON c.cod_vet = v.cod
    WHERE c.dt BETWEEN dt_ini AND dt_fim
    ORDER BY c.dt;
END;
$$;

SELECT * FROM listarConsultasPeriodo('2023-10-01', '2023-10-31');


-- 5. Crie uma função que receba os dados do veterinario por parâmetro, armazene na tabela “veterinario” e 
--   retorne todos os veterinários com a mesma especialidade.

CREATE OR REPLACE FUNCTION veterinario_especialidade(
    nome_p VARCHAR(100),
    crmv_p NUMERIC(10),
    especialidade_p VARCHAR(50),
    fone_p VARCHAR(50),
    email_p VARCHAR(100), 
    cod_end_p INT
)
RETURNS TABLE (
    cod INT, 
    nome VARCHAR(100), 
    crmv NUMERIC(10), 
    especialidade VARCHAR(50), 
    email VARCHAR(100), 
    fone VARCHAR(50), 
    cod_end INT
) 
AS

$$

DECLARE 
    novo_cod INT;
BEGIN
    -- Inserindo o veterinário na tabela e armazenando o código gerado
    INSERT INTO Veterinario (nome, crmv, especialidade, email, fone, cod_end) 
    VALUES (nome_p, crmv_p, especialidade_p, email_p, fone_p, cod_end_p)
    RETURNING cod INTO novo_cod;

    -- Retornando todos os veterinários com a mesma especialidade
    RETURN QUERY
    SELECT * FROM Veterinario WHERE especialidade = especialidade_p;
END;

$$

LANGUAGE plpgsql;

SELECT * FROM veterinario_especialidade(
    'Carlos Eduardo', 
    1234567890, 
    'Clinico Geral', 
    '(11) 99999-9999', 
    'carlos.eduardo@email.com', 
    3
);

-- 6. Crie um procedimento para adicionar um novo pet, associando-o a um responsável existente.
CREATE OR REPLACE PROCEDURE add_pet(
    nome_p varchar(100),
    raca_p varchar(50),
    peso_p decimal(5,2),
    data_nasc_p date,
    cod_resp_p integer
)AS

$$ 

INSERT INTO Pet (nome, raca, peso, data_nasc, cod_resp)
VALUES (nome_p, raca_p, peso_p, data_nasc_p, cod_resp_p);

$$

LANGUAGE SQL;

CALL add_pet('Thor', 'Golden Retriever', 30.5, '2022-08-15', 1);

-- 7. Escreva uma função que conte quantos pets um determinado responsável possui.
CREATE OR REPLACE FUNCTION contador_resp(cod_resp_p INT)
RETURNS INT 
AS

$$

DECLARE 
    total_pets INT;
BEGIN
	SELECT COUNT(*) INTO total_pets
	FROM Pet 
	WHERE cod_resp = cod_resp_p;

	RETURN total_pets;

$$
LANGUAGE SQL;

-- 8. Faça uma função que calcule a idade atual de um pet com base na sua data de nascimento.

CREATE OR REPLACE FUNCTION calc_pet(cod_pet_p INT)
RETURNS INT 
LANGUAGE plpgsql
AS
$$
DECLARE 
    idade INT;
BEGIN
    -- Calcula a idade do pet com base na data atual e na data de nascimento
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, data_nasc)) INTO idade
    FROM Pet
    WHERE cod = cod_pet_p;

    RETURN idade;
END;
$$;


-- 9. Função que retorna todas as consultas agendadas de um determinado veterinário
--     em uma data especifica.

SELECT *
FROM veterinario

CREATE OR REPLACE FUNCTION consultas_vet(cod_vet_p INT, data_p DATE)
RETURNS TABLE (data_consulta DATE, horario TIME, nome_pet VARCHAR(100), nome_resp VARCHAR(100), fone_resp VARCHAR(50))
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
    SELECT c.dt, c.horario, p.nome AS nome_pet, r.nome AS nome_resp, r.fone AS fone_resp
    FROM Consulta c
    JOIN Pet p ON c.cod_pet = p.cod
    JOIN Responsavel r ON p.cod_resp = r.cod
    WHERE c.cod_vet = cod_vet_p AND c.dt = data_p;
END;
$$;



-- 10. Procedimento que retorna o nome e telefone do responsável de um determinado pet
-- 	   Faça uso do OUT para retornar os valores solicitados.

CREATE OR REPLACE PROCEDURE get_responsavel_pet(
    IN cod_pet_p INT,
    OUT nome_responsavel VARCHAR(100),
    OUT telefone_responsavel VARCHAR(50)
)
LANGUAGE plpgsql
AS
$$
BEGIN
    SELECT r.nome, r.fone
    INTO nome_responsavel, telefone_responsavel
    FROM Responsavel r
    JOIN Pet p ON p.cod_resp = r.cod
    WHERE p.cod = cod_pet_p;
END;
$$;

CALL get_responsavel_pet(3, NULL, NULL);


-- 11. Função que retorna o nome do responsável pelo CPF ou uma mensagem caso não encontrado.

--> COALESCE retornar o primeiro valor não nulo
-- Evita valores NULL inesperados, substituindo-os por valores padrões.
-- Melhora relatórios e consultas, evitando exibir campos vazios.
-- Garante compatibilidade em cálculos, evitando problemas de NULL em operações matemáticas.
SELECT COALESCE(null, 'Responsável não encontrado');

SELECT * FROM Responsavel

CREATE OR REPLACE FUNCTION nomePorCPF(cpf_p varchar(12))
RETURNS VARCHAR AS
$$
SELECT COALESCE(
	(SELECT nome FROM Responsavel WHERE cpf = cpf_p), 'Responsável não encontrado')
$$
LANGUAGE SQL;

SELECT nomePorCPF('1111111111')
SELECT nomePorCPF('1111111112')

-- 12. Crie uma função que receba um código de veterinário e retorne o total de consultas realizadas por ele.

CREATE OR REPLACE FUNCTION total_consultas_veterinario(cod_vet_p INT)
RETURNS INT 
LANGUAGE plpgsql
AS
$$
DECLARE 
    total_consultas INT;
BEGIN
    SELECT COUNT(*) INTO total_consultas
    FROM Consulta
    WHERE cod_vet = cod_vet_p;

    RETURN total_consultas;
END;
$$;

SELECT total_consultas_veterinario(2);

