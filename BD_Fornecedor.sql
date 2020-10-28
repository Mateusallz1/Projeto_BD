CREATE TABLE Fornecedor(
    cod_fornecedor serial not null,
    nome varchar(125),
	cnpj bigint unique,
	localizacao varchar(500),
    telefone bigint,
    constraint priForn primary key(cod_fornecedor)
);


--======================================= TRIGGER'S FORNECEDOR ========================================================--
-- TRIGGER FORNECEDOR
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

--====================================FUNCTION FORNECEDOR======================================================--
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