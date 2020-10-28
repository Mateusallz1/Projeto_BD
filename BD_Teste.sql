CREATE TABLE Cliente ( --cod_cliente, nome, cpf, telefone, dt_nasc
	cod_cliente serial not null,
	nome varchar(125),
	cpf bigint unique,
	telefone bigint,
	dt_nasc date, --ano-mês-dia
	constraint priVend primary key(cod_cliente)
);

SELECT * FROM CATEGORIA

SELECT REALIZA_INSERCAO('Anastácia', 1111111111, 998674004, '1980-12-01')
SELECT REALIZA_INSERCAO('João', 2222222222, 998685005, '1990-01-24')
SELECT REALIZA_INSERCAO('José', 3333333333, 998686006, '1980-02-13')

CREATE TABLE Vendedor( --COD_VENDEDOR, COD_CATEGORIA, NOME, CPF, TELEFONE, DT_NASC
	cod_vendedor serial not null,
	cod_categoria int not null,
	nome varchar(125),
	cpf bigint unique,
	telefone bigint,
	dt_nasc date,
	constraint priVende primary key(cod_vendedor),
	constraint stngVendCat foreign key(cod_categoria) references categoria(cod_categoria)
);
SELECT * FROM VENDEDOR

SELECT REALIZA_INSERCAO('Estagiário', 'André', 1111111112, 988817654, '1960-12-01')
SELECT REALIZA_INSERCAO('Junior', 'Carlos', 1111111113, 981402526, '1988-10-02')
SELECT REALIZA_INSERCAO('Master', 'Ricardo', 1111111114, 981405658, '1970-02-25')

CREATE TABLE Categoria( --COD_CATEGORIA, NOME, DESCRICAO, VALOR_SALARIO, COMISSAO
	cod_categoria serial not null,
	nome varchar(125) unique,
	descricao varchar(500),
	valor_salario float,
	comissao float,
	constraint priCat primary key(cod_categoria)
);

SELECT * FROM CATEGORIA

SELECT REALIZA_INSERCAO('Estagiário', 'Funcionário que ingressou na empresa para estagiar.', 900, 0)
SELECT REALIZA_INSERCAO('Junior', 'Funcionário recém contratado.', 1300, 1)
SELECT REALIZA_INSERCAO('Master', 'FUncionário que já vendeu mais de R$ 20,000.', 2000, 2)

CREATE TABLE Produto( --NOME, QUANTIDADE, PRECO
	cod_produto serial not null,
	nome varchar(125), 
	quantidade int, 
	preco float, 
	constraint priProd primary key(cod_produto)
);

SELECT * FROM PRODUTO

SELECT REALIZA_INSERCAO('Teclado', 15, 300)
SELECT REALIZA_INSERCAO('Mouse', 30, 150)
SELECT REALIZA_INSERCAO('Headphone', 25, 350)

--==================================== TRIGGER'S ==========================================--
-- TRIGGER DA TABELA VENDEDOR
CREATE OR REPLACE VIEW Visao_Vendedor AS SELECT * FROM Vendedor;
CREATE TRIGGER Trig_Vendedor INSTEAD OF INSERT OR UPDATE ON Visao_Vendedor FOR EACH ROW EXECUTE PROCEDURE Checa_Vendedor();

CREATE OR REPLACE FUNCTION Checa_Vendedor() RETURNS TRIGGER AS 
$$
BEGIN
	IF (new.nome is NULL or new.cpf is NULL) THEN
		RAISE EXCEPTION 'Você inseriu valores nulos. Tente novamente.';
			
	ELSEIF Data_Valida(new.dt_nasc) is false THEN
		RAISE EXCEPTION 'Você inseriu uma data inválida. Tente novamente.';
		
	ELSEIF Confere_CPF(new.cpf) is false THEN
		RAISE EXCEPTION 'Você inseriu um CPF inválido.';
		
	ELSEIF Confere_Telefone(new.telefone) is false THEN
		RAISE EXCEPTION 'Você inseriu um número de telefone inválido.';
			
	ELSE
		INSERT INTO Vendedor VALUES (default, new.cod_categoria, new.nome, new.cpf, new.telefone, new.dt_nasc);
		RETURN NEW;
	END IF;
	RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

-- TRIGGER DA TABELA CATEGORIA
CREATE OR REPLACE VIEW Visao_Categoria AS SELECT * FROM Categoria;
CREATE TRIGGER Trig_Categoria INSTEAD OF INSERT OR UPDATE ON Visao_Categoria FOR EACH ROW EXECUTE PROCEDURE Checa_Categoria();

CREATE OR REPLACE FUNCTION Checa_Categoria() RETURNS TRIGGER AS 
$$
BEGIN
	IF new.nome is NULL THEN
		RAISE EXCEPTION 'Dados inseridos em nome são inválidos. Tente novamente.';
			
	ELSEIF new.valor_salario < 0 or new.valor_salario is NULL THEN
		RAISE EXCEPTION 'Dados inseridos em salário são inválidos. Tente novamente.';
	
	ELSE
		INSERT INTO Categoria VALUES(DEFAULT, new.nome, new.descricao, new.valor_salario, new.comissao);
		RETURN NEW;
	END IF;
	RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

--TRIGGER DA TABELA CLIENTE
CREATE or REPLACE VIEW visao_cliente AS SELECT * FROM Cliente;
CREATE TRIGGER Trig_Cliente INSTEAD OF INSERT ON visao_cliente FOR EACH ROW EXECUTE PROCEDURE checa_cliente();

CREATE OR REPLACE FUNCTION checa_cliente() RETURNS TRIGGER AS 
$$
BEGIN

	IF (new.nome is NULL or new.cpf is NULL) THEN
		RAISE EXCEPTION 'Você inseriu valores nulos. Tente novamente.';
			
	ELSEIF Data_Valida(new.dt_nasc) is false THEN
		RAISE EXCEPTION 'Você inseriu uma data inválida. Tente novamente.';
		
	ELSEIF Confere_CPF(new.cpf) is false THEN
		RAISE EXCEPTION 'Você inseriu um CPF inválido.';
		
	ELSEIF Confere_Telefone(new.telefone) is false THEN
		RAISE EXCEPTION 'Você inseriu um número de telefone inválido.';
			
	ELSE
		INSERT INTO cliente VALUES (default, new.nome, new.cpf, new.telefone, new.dt_nasc);
		RETURN NEW;
	END IF;
	RETURN NULL; --new é por linha, null é por instrução.
END;
$$ LANGUAGE plpgsql;

--TRIGGER DA TABELA PRODUTO
CREATE OR REPLACE VIEW Visao_Produto AS SELECT * FROM Produto;
CREATE TRIGGER Trig_Produto INSTEAD OF INSERT OR UPDATE ON Visao_Produto FOR EACH ROW EXECUTE PROCEDURE Checa_Produto();

CREATE OR REPLACE FUNCTION Checa_Produto() RETURNS TRIGGER AS $$
BEGIN
	IF new.nome IS NULL THEN
		RAISE EXCEPTION 'Você inseriu nome nulo. Tente novamente.';
	
	ELSEIF new.quantidade < 0 THEN
		RAISE EXCEPTION 'Você inseriu uma quantidade negativa. Tente novamente.';
		
	ELSEIF new.preco < 0 THEN
		RAISE EXCEPTION 'Você inseriu um preço negativo. Tente novamente.';
		
	ELSE
		INSERT INTO Produto VALUES(DEFAULT, new.nome, new.quantidade, new.preco);
		RETURN NEW;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

--==================================== FUNCTIONS  ==========================================--
--INSERT FUNCTION VENDEDOR; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), varchar(125), bigint, bigint, date) RETURNS Void AS $$
DECLARE
	cod_cat int;
BEGIN
	cod_cat = retorna_cod_cat($1);
	INSERT INTO Visao_Vendedor VALUES(DEFAULT, cod_cat, $2, $3, $4, $5);
END;
$$ LANGUAGE 'plpgsql';

-- Retorna o código da categoria dado um nome como argumento;
CREATE OR REPLACE FUNCTION Retorna_Cod_Cat(varchar(125)) RETURNS Int AS $$
DECLARE
	cod_cat int;
BEGIN
	SELECT cod_categoria INTO cod_cat FROM Categoria WHERE nome ilike $1;
	RETURN cod_cat;
END;									   
$$ LANGUAGE 'plpgsql';

--INSERT FUNCTION CATEGORIA; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), varchar(500), float, float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Categoria VALUES(DEFAULT, $1, $2, $3, $4);
END;
$$ LANGUAGE 'plpgsql';

--INSERT FUNCTION CLIENTE; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), bigint, int, date) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Cliente VALUES(DEFAULT, $1, $2, $3, $4);
END;
$$ LANGUAGE 'plpgsql';

--INSERT FUNCTION PRODUTO; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), int, float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Produto VALUES(DEFAULT, $1, $2, $3);
END;
$$ LANGUAGE 'plpgsql';

--CONFERE CPF;
CREATE FUNCTION Confere_CPF(CPF bigint) RETURNS BOOLEAN AS $$
BEGIN
	IF $1 > 9999999999 or $1 < 999999999 THEN
		RETURN false;
	ELSE
		RETURN true;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

--CONFERE NUMERO TEL;
CREATE OR REPLACE FUNCTION Confere_Telefone(telfone bigint) RETURNS BOOLEAN AS $$
BEGIN
	IF $1 > 999999999 or $1 < 99999999 THEN
		RETURN false;
	ELSE
		RETURN true;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

--VALIDA DATA NASC;
CREATE OR REPLACE FUNCTION Data_Valida(dt_nasc date) RETURNS BOOLEAN AS $$
BEGIN
	IF (current_date - $1) / 365 > 115 then
		RETURN false;
	ELSE
		RETURN true;
	END IF;
END;
$$ LANGUAGE 'plpgsql';




