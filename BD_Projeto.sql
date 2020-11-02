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

CREATE TABLE Fornecedor(
    cod_fornecedor serial not null,
    nome varchar(125),
	cnpj bigint unique,
	localizacao varchar(500),
    telefone bigint,
    constraint priForn primary key(cod_fornecedor)
);

CREATE TABLE Compra(
    cod_compra serial not null,
    cod_fornecedor int not null,
    cod_vendedor int not null,
    data_compra timestamp,
    valor_total float,
    status_compra boolean,
    constraint priCompra primary key(cod_compra), 
    constraint stngCompraForn foreign key(cod_fornecedor) references Fornecedor(cod_fornecedor),
    constraint stngCompraVend foreign key(cod_vendedor) references Vendedor(cod_vendedor)
);

CREATE TABLE Item_Compra(
	cod_item_compra serial not null,
    cod_compra int not null,
    cod_produto int not null,
    quant_comprada int,
    constraint priItemC primary key(cod_item_compra),
    constraint stngItemCCompra foreign key(cod_compra) references Compra(cod_compra),
    constraint stngItemCProd foreign key(cod_produto) references Produto(cod_produto) 
);

CREATE TABLE Produto_Fornecido(
    cod_fornecedor int not null,
    cod_produto int not null,
    valor_unitario float,
    constraint stngFornProd foreign key(cod_produto) references,
    constraint stngFornForn foreign key(cod_fornecedor) references
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

-- TRIGGER DA TABELA FORNECEDOR
CREATE OR REPLACE VIEW Visao_Fornecedor AS SELECT * FROM Fornecedor;
CREATE TRIGGER Trig_Fornecedor INSTEAD OF INSERT OR UPDATE ON Visao_Fornecedor FOR EACH ROW EXECUTE PROCEDURE Checa_Fornecedor();

CREATE OR REPLACE FUNCTION Checa_Fornecedor() RETURNS TRIGGER AS 
$$
BEGIN
	IF (new.nome is NULL or new.cnpj is NULL) THEN
		RAISE EXCEPTION 'Você inseriu valores nulos. Tente novamente.';
			
	ELSEIF Confere_CNPJ(new.cnpj) is false THEN
		RAISE EXCEPTION 'Você inseriu um CNPJ inválido.';
		
	ELSEIF Confere_Telefone(new.telefone) is false THEN
		RAISE EXCEPTION 'Você inseriu um número de telefone inválido.';
			
	ELSE
		INSERT INTO Fornecedor VALUES(default, new.nome, new.cnpj, new.localizacao, new.telefone);
		RETURN NEW;
	END IF;
	RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

--==================================== FUNCTIONS  ==========================================--
--INSERT FUNCTION VENDEDOR; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), varchar(125), bigint, bigint, date) RETURNS Void AS $$
DECLARE
	cod_cat int;
BEGIN
	SELECT cod_categoria INTO cod_cat FROM Categoria WHERE nome ilike $1;
	INSERT INTO Visao_Vendedor VALUES(DEFAULT, cod_cat, $2, $3, $4, $5);
	RAISE NOTICE 'O Vendedor % foi inserido com sucesso!', $1;

END;
$$ LANGUAGE 'plpgsql';

--INSERT FUNCTION CATEGORIA; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), varchar(500), float, float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Categoria VALUES(DEFAULT, $1, $2, $3, $4);
	RAISE NOTICE 'A Categoria % foi inserida com sucesso!', $1;

END;
$$ LANGUAGE 'plpgsql';

--INSERT FUNCTION CLIENTE; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), bigint, int, date) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Cliente VALUES(DEFAULT, $1, $2, $3, $4);
	RAISE NOTICE 'O Cliente % foi inserido com sucesso!', $1;

END;
$$ LANGUAGE 'plpgsql';

--INSERT FUNCTION PRODUTO; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), int, float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Produto VALUES(DEFAULT, $1, $2, $3);
	RAISE NOTICE 'O Produto % foi inserido com sucesso!', $1;

END;
$$ LANGUAGE 'plpgsql';

-- INSERT FUNCTION FORNECEDOR
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), bigint, varchar(500), bigint) RETURNS Void AS $$
BEGIN
	INSERT INTO Visao_Fornecedor VALUES(default, $1, $2, $3, $4);
END;
$$ LANGUAGE 'plpgsql';

-- CONFERE CNPJ
CREATE OR REPLACE FUNCTION Confere_CNPJ(bigint) RETURNS BOOLEAN AS $$
BEGIN
    IF $1 > 99999999999 or $1 < 9999999999 THEN
        RETURN false;
    END IF;
    RETURN true;
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

--REALIZA VENDA (nome_vendedor, nome_cliente, nome_produto)
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
	SELECT preco INTO valor_produto FROM Produto WHERE nome ILIKE $3;
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
		RAISE NOTICE 'O produto requerido não pode ser vendido pois sua quantidade é 0.';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Finaliza Venda (cod_venda)
CREATE OR REPLACE FUNCTION Finaliza_Venda(int) RETURNS Void AS $$
BEGIN
	IF $1 in(SELECT cod_venda FROM Venda)THEN
		UPDATE Venda SET status_venda = false WHERE cod_venda = $1;
	ELSE
		RAISE NOTICE 'Código da venda não foi encontrado.';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

-- REALIZA COMPRA (NOME VENDEDOR, NOME PRODUTO, NOME FORNECEDOR, QUANTIDADE)
CREATE OR REPLACE FUNCTION Realiza_Compra(varchar(125), varchar(125), varchar(125), int) RETURNS Void AS $$
DECLARE
    cod_vend int;
    cod_forn int;
    cod_prod int;
    cod_comp int;
    valor_tot float;
    status_c boolean;
    valor_total_compra float;

BEGIN
    SELECT cod_vendedor INTO cod_vend FROM Vendedor WHERE nome ILIKE $1; -- Pega o código do vendedor.
	SELECT cod_fornecedor INTO cod_forn FROM Fornecedor WHERE nome ILIKE $3; -- Pega o código do fornecedor.
    SELECT cod_produto INTO cod_prod FROM Produto WHERE nome ILIKE $2; -- Pega o código do produto.
    SELECT cod_compra INTO cod_comp FROM Compra NATURAL JOIN Vendedor WHERE cod_vendedor = cod_vend; -- Pega o código da compra relacionada ao vendedor.
    SELECT status_compra INTO status_c FROM Compra WHERE cod_compra = cod_comp; -- Pega o status de uma compra.
    SELECT valor_unitario INTO valor_tot FROM Produto_Fornecido WHERE cod_produto = cod_prod; -- Pega o valor unitário do produto escolhido.
    valor_total_compra = valor_tot * $4; -- Pega o valor total = (valor da compra * quantidade).

    IF cod_comp in(SELECT cod_compra FROM Compra) AND status_c is true THEN
		UPDATE Compra SET valor_total = valor_total + valor_total_compra WHERE cod_compra = cod_comp;
		INSERT INTO Item_Compra VALUES(DEFAULT, cod_comp, cod_prod, $4);
		UPDATE Produto SET quantidade = quantidade + $4 WHERE cod_produto = cod_prod;
		RAISE NOTICE 'Compra realizada com sucesso!';

    ELSEIF cod_comp not in(SELECT cod_compra FROM Compra) or cod_comp is NULL or cod_comp in(SELECT cod_compra FROM Compra) AND status_c is false THEN
        INSERT INTO Compra VALUES(DEFAULT, cod_forn, cod_vend, localtimestamp, valor_total_compra, true);
        SELECT cod_compra INTO cod_comp FROM Compra NATURAL JOIN Vendedor WHERE cod_vendedor = cod_vend;
        INSERT INTO Item_Compra VALUES(DEFAULT, cod_comp, cod_prod, $4);
        UPDATE Produto SET quantidade = quantidade + $4 WHERE cod_produto = cod_prod;
        RAISE NOTICE 'Compra realizada com sucesso!';

    ELSE
        RAISE NOTICE 'A compra não foi realizada! Verifique os dados e tente novamente!';

    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- REALIZA COMPRA SEM FORNECEDOR(NOME VENDEDOR, NOME PRODUTO, QUANTIDADE)
CREATE OR REPLACE FUNCTION Realiza_Compra(varchar(125), varchar(125), int) RETURNS Void AS $$
DECLARE
    cod_vend int;
    cod_prod int;
    cod_forn int;
    cod_comp int;
    status_c boolean;
    valor_uni float;
    valor_total_compra float;

BEGIN
    SELECT cod_vendedor INTO cod_vend FROM Vendedor WHERE nome ILIKE $1; -- Pega o código do vendedor.
    SELECT cod_produto INTO cod_prod FROM Produto WHERE nome ILIKE $2; -- Pega o código do produto.
    SELECT cod_compra INTO cod_comp FROM Compra NATURAL JOIN Vendedor WHERE cod_vendedor = cod_vend; -- Pega o código da compra relacionada ao vendedor.
    SELECT status_compra INTO status_c FROM Compra WHERE cod_compra = cod_comp; -- Pega o status de uma compra.
    SELECT valor_unitario INTO valor_uni FROM Produto_Fornecido WHERE cod_produto = cod_prod; 
    valor_total_compra = valor_uni * $3;
    cod_forn = Melhor_Preco(cod_prod);

    IF cod_comp in(SELECT cod_compra FROM Compra) AND status_c is true THEN
        UPDATE Compra SET valor_total = valor_total + valor_total_compra WHERE cod_compra = cod_comp;
        INSERT INTO Item_Compra VALUES(DEFAULT, cod_comp, cod_prod, $3);
        UPDATE Produto SET quantidade = quantidade + $3 WHERE cod_produto = cod_prod;
        RAISE NOTICE 'Compra realizada com sucesso!';

    ELSEIF cod_comp not in(SELECT cod_compra FROM Compra) or cod_comp is NULL or cod_comp in(SELECT cod_compra FROM Compra) AND status_c is false THEN
        INSERT INTO Compra VALUES(DEFAULT, cod_forn, cod_vend, localtimestamp, valor_total_compra, true);
        UPDATE Compra SET status_compra = true WHERE cod_compra = cod_comp;
        INSERT INTO Item_Compra VALUES(DEFAULT, cod_comp, cod_prod, $3);
        UPDATE Produto SET quantidade = quantidade + $3 WHERE cod_produto = cod_prod;
        RAISE NOTICE 'Compra realizada com sucesso!';
    
    ELSE
        RAISE NOTICE 'A compra não foi realizada! Verifique os dados e tente novamente!';

    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Recebe o código do produto e retorna o código do fornecedor com o menor preço.
CREATE OR REPLACE FUNCTION Melhor_Preco(int) RETURNS int AS $$
DECLARE
	cod_forn int;
BEGIN
    SELECT cod_fornecedor INTO cod_forn FROM Produto_Fornecido WHERE valor_unitario in(SELECT min(valor_unitario) FROM Produto_Fornecido) and $1 in(SELECT cod_produto FROM Produto_Fornecido) limit 1;
    RETURN cod_forn;
END;
$$ LANGUAGE 'plpgsql';

-- Finaliza Compra (cod_compra)
CREATE OR REPLACE FUNCTION Finaliza_Compra(int) RETURNS Void AS $$
BEGIN
	IF $1 in(SELECT cod_compra FROM Compra) THEN
		UPDATE Compra SET status_compra = false WHERE cod_compra = $1;
        RAISE NOTICE 'Compra finalizada com sucesso!';

	ELSE
		RAISE NOTICE 'Código da compra não foi encontrado.';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

-- RECEBE O NOME DO FORNECEDOR, PRODUTO, E O VALOR UNITÁRIO; CHECA SE OS DOIS EXISTEM; FAZ A INSERÇÃO NA TABELA Produto_Fornecido.
CREATE OR REPLACE FUNCTION Fornecimento(varchar(125), varchar(125), float) RETURNS Void AS $$ -- nome_forn, nome_prod, valor_unitário
DECLARE
    cod_forn int;
    cod_prod int;
BEGIN

    SELECT cod_fornecedor INTO cod_forn FROM Fornecedor WHERE nome ILIKE $1;
    SELECT cod_produto INTO cod_prod FROM Produto WHERE nome ILIKE $2;

    IF cod_forn IN(SELECT cod_fornecedor FROM Fornecedor) THEN
		IF cod_prod IN(SELECT cod_produto FROM Produto) THEN
			INSERT INTO Produto_Fornecido VALUES(cod_forn, cod_prod, $3);
		ELSE
			RAISE NOTICE 'Código do produto não encontrado.';
		END IF;
    ELSE
        RAISE NOTICE 'Código do fornecedor não encontrado.';
    END IF;

END;
$$ LANGUAGE 'plpgsql';




