CREATE TABLE Cliente ( --cod_cliente, nome, cpf, telefone, dt_nasc
	cod_cliente serial not null,
	nome varchar(125),
	cpf bigint unique,
	telefone bigint,
	dt_nasc date --ano-mês-dia
	constraint priVend primary key(cod_cliente)
);

CREATE TABLE Vendedor( --COD_VENDEDOR, COD_CATEGORIA, NOME, CPF, TELEFONE
	cod_vendedor serial not null,
	cod_categoria int not null,
	nome varchar(125),
	cpf bigint unique,
	telefone bigint,
	dt_nasc date,
	constraint priVend primary key(cod_vendedor),
	constraint stngVendCat foreign key(cod_categoria) references categoria(cod_categoria)
);

CREATE TABLE Categoria( --COD_CATEGORIA, NOME, DESCRICAO, VALOR_SALARIO, COMISSAO
	cod_categoria serial not null,
	nome varchar(125) unique,
	descricao varchar(500),
	valor_salario float,
	comissao float,
	constraint priCat primary key(cod_categoria)
);

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
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), int, varchar(500), float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Produto VALUES(DEFAULT, $1, $2, $3, $4);
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




