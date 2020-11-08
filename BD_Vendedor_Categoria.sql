CREATE TABLE Vendedor( --COD_VENDEDOR, COD_CATEGORIA, NOME, CPF, TELEFONE, DT_NASC
	cod_vendedor serial not null,
	cod_categoria int not null,
	nome varchar(125),
	cpf bigint unique, -- 14
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

--======================================= TRIGGER'S PRODUTO ========================================================--
-- TRIGGER DA TABELA VENDEDOR
CREATE OR REPLACE VIEW Visao_Vendedor AS SELECT * FROM Vendedor;
CREATE TRIGGER Trig_Vendedor INSTEAD OF INSERT OR UPDATE ON Visao_Vendedor FOR EACH ROW EXECUTE PROCEDURE Checa_Vendedor();
DROP FUNCTION CHECA_VENDEDOR CASCADE ON VENDEDOR

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

--===================================== FUNCTION INSERT ===========================================================--
--INSERT FUNCTION VENDEDOR; INT, VARCHAR, BIGINT, BIGINT, DATE
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

--INSERT FUNCTION CATEGORIA; VARCHAR, VARCHAR, FLOAT, FLOAT
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(125), varchar(500), float, float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Categoria VALUES(DEFAULT, $1, $2, $3, $4);
END;
$$ LANGUAGE 'plpgsql';

select salario_funcionario('cassia', 'novembro');

-- Retorna o salário de um funcionário relacionado ao mês que foi requerido. (Nome do Funcionário, nome do mês);
CREATE OR REPLACE FUNCTION Salario_Funcionario(varchar(125), varchar(20)) RETURNS float AS $$
DECLARE
	salario float;
	mes int;
    cod_vend int;

BEGIN
    SELECT cod_vendedor INTO cod_vend FROM Vendedor WHERE nome ILIKE $1;

	IF cod_vend IN(SELECT cod_vendedor FROM Vendedor WHERE nome ILIKE $1) THEN
        IF $2 ILIKE 'janeiro' THEN
            mes = 1;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'fevereiro' THEN
            mes = 2;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'março' THEN
            mes = 3;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'abril' THEN
            mes = 4;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'maio' THEN
            mes = 5;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'junho' THEN
            mes = 6;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'julho' THEN
            mes = 7;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'agosto' THEN
            mes = 8;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'setembro' THEN
            mes = 9;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;
        
        ELSEIF $2 ILIKE 'outubro' THEN
            mes = 10;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'novembro' THEN
            mes = 11;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;

        ELSEIF $2 ILIKE 'dezembro' THEN
            mes = 12;
            salario = Salario_Final($1, mes, cod_vend);
            RETURN salario;
        
        ELSE
            RAISE NOTICE 'O mês % não foi identificado. Confira os dados inseridos e tente novamente.', $2;
        END IF;
    ELSE 
        RAISE NOTICE 'O Vendedor % não está inserido no BD.', $1;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Calcula o valor do salario + a comissão; (Nome do Funcionário, mês, Código do Vendedor);
CREATE OR REPLACE FUNCTION Salario_Final(varchar(125), int, int) RETURNS FLOAT AS $$
DECLARE
	quant_vend float;
	comissao_vend float;
	salario float;
    mes int;

BEGIN
    mes = $2;
	SELECT comissao INTO comissao_vend FROM Categoria C JOIN Vendedor V ON v.cod_categoria = c.cod_categoria WHERE cod_vendedor = $3;
    SELECT SUM(valor_total_vendido) INTO quant_vend FROM venda WHERE cod_vendedor = $3 AND EXTRACT(MONTH FROM data_venda) = mes GROUP BY cod_vendedor;
    
    salario = salario_da_categoria($1);
    salario = salario + (quant_vend * (comissao_vend / 100));
    RETURN salario;
END;
$$ LANGUAGE 'plpgsql';

-- SELECT comissao INTO comissao_final FROM Categoria NATURAL JOIN Vendedor WHERE cod_vendedor = cod_vend;
-- SELECT nome, salario FROM Vendedor NATURAL JOIN Venda WHERE extract(month from data_venda) = $1 and extract(year from data_venda) = extract(year from localtimestamp);
select * from venda

-- Retorna o valor do salário de determinado funcionário. (Nome do Funcionário);
CREATE OR REPLACE FUNCTION Salario_da_Categoria(varchar(125)) RETURNS FLOAT AS $$
DECLARE 
	salario float;
	cod_vend int;
BEGIN
	SELECT cod_vendedor INTO cod_vend FROM Vendedor WHERE nome ilike $1;
	SELECT valor_salario INTO salario FROM Categoria C JOIN Vendedor V ON v.cod_categoria = c.cod_categoria WHERE cod_vendedor = cod_vend;
	RETURN salario;
END;
$$ LANGUAGE 'plpgsql';