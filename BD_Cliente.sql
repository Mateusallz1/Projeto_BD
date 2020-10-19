CREATE TABLE Cliente (
	cod_cliente serial not null primary key,
	nome varchar(125),
	cpf bigint unique,
	telefone bigint,
	dt_nasc date 
);

--==========================================TRIGGER CLIENTE======================================================--
--== INSTEAD OF evita que coloque na visão, e bota diretamente na tabela da visão ==--
-- Toda vez que for feito um insert na view de cliente, o trigger dispara.

--DROP TRIGGER trig_cliente ON cliente CASCADE;
CREATE or REPLACE VIEW visao_cliente AS SELECT * FROM Cliente;
CREATE TRIGGER Trig_Cliente INSTEAD OF INSERT ON visao_cliente FOR EACH ROW EXECUTE PROCEDURE checa_cliente();

CREATE OR REPLACE FUNCTION checa_cliente() RETURNS TRIGGER AS 
$$
	BEGIN
		--Verifica se os dados que serão inseridos são nulos.
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
		RETURN NULL; 
	END;
$$ LANGUAGE plpgsql;

--==========================================FUNCTION CLIENTE======================================================--
--INSERT FUNCTION
CREATE OR REPLACE FUNCTION Realiza_Insercao(nome varchar(125), cpf bigint, telefone int, dt_nasc date) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Cliente VALUES(DEFAULT, $1, $2, $3, $4);
END;
$$ LANGUAGE 'plpgsql';

select cpf in(select visão_cliente)

--CONFERE CPF;
CREATE OR REPLACE FUNCTION Confere_CPF(CPF bigint) RETURNS BOOLEAN AS $$
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

--===============================================================================================================--