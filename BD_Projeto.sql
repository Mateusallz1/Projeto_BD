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

CREATE TABLE Produto( --NOME, QUANTIDADE, PRECO
	cod_produto serial not null,
	nome varchar(125	), 
	quantidade int, 
	preco float, 
	constraint priProd primary key(cod_produto)
);

CREATE TABLE Venda( --cod_venda, cod_vendedor, cod_cliente, quant_itens_vendidos, valor_total_vendido, data_venda, status_venda
	cod_venda serial not null,
	cod_vendedor int not null,
	cod_cliente int not null,
	quant_itens_vendidos int,
	valor_total_vendido float,
	data_venda timestamp,
	status_venda boolean,
	constraint priVenda primary key(cod_venda),
	constraint stngVendaVendedor foreign key(cod_vendedor) references Vendedor(cod_vendedor),
	constraint stngVendaCliente foreign key(cod_cliente) references Cliente(cod_cliente)
);

CREATE TABLE Item_Venda( --cod_produto, cod_venda, valor_total, quant_vendida, data_venda
	cod_produto int not null,
	cod_venda int not null,
	valor_total float,
	quant_vendida int not null,
	data_venda timestamp,
	constraint priItemVenda primary key(cod_produto, cod_venda),
	constraint stngItemVendaProd foreign key(cod_produto) references Produto(cod_produto),
	constraint stngItemVendaVenda foreign key(cod_venda) references Venda(cod_venda)
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
	SELECT cod_categoria INTO cod_cat FROM Categoria WHERE nome ilike $1;
	INSERT INTO Visao_Vendedor VALUES(DEFAULT, cod_cat, $2, $3, $4, $5);
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

--REALIZA VENDA
CREATE OR REPLACE FUNCTION Realiza_Venda(varchar(125), varchar(125), varchar(125)) RETURNS VOID AS $$
DECLARE --nome vendedor, nome cliente, nome produto
	codig_cli int;
	codig_vende int;
	codig_prod int;
	codig_venda int;
	valor_produto float;
	quant int;
	stts_venda boolean;
	
BEGIN
	SELECT cod_venda INTO codig_venda FROM Cliente NATURAL JOIN Venda WHERE nome ilike $2;
	SELECT cod_vendedor INTO codig_vende FROM Vendedor WHERE nome ILIKE $1;
	SELECT cod_cliente INTO codig_cli FROM Cliente WHERE nome ILIKE $2;
	SELECT cod_produto INTO codig_prod FROM Produto WHERE nome ILIKE $3;
	SELECT preco INTO valor_produto FROM Produto WHERE  nome ILIKE $3;
	SELECT cod_venda INTO codig_venda FROM Cliente NATURAL JOIN Venda WHERE cod_cliente = codig_cli;
	SELECT quantidade INTO quant FROM Produto WHERE nome ILIKE $3;
	SELECT status_venda INTO stts_venda FROM Venda WHERE cod_venda = codig_venda;
	
	IF quant > 0 THEN
		UPDATE Produto SET quantidade = quantidade - 1 WHERE cod_produto = codig_prod;

		IF (codig_venda) in(SELECT cod_venda FROM Venda) and stts_venda is true THEN
			UPDATE Venda SET valor_total_vendido = valor_total_vendido + valor_produto WHERE cod_venda = codig_venda;
			INSERT INTO Item_venda VALUES(cod_prod, codig_venda, valor_total, 1, localtimestamp);
		ELSE
			INSERT INTO Venda VALUES(default, codig_vende, codig_cli, 1, valor_produto, localtimestamp, true);
			SELECT cod_venda INTO codig_venda FROM Cliente NATURAL JOIN Venda WHERE cod_cliente = codig_cli;
			INSERT INTO Item_Venda VALUES(codig_prod, codig_venda, valor_produto, 1, localtimestamp);
		END IF;
	ELSE 
		RAISE EXCEPTION 'A quantidade do produto requerido é zero.';
	END IF;
END;
$$ LANGUAGE 'plpgsql';


