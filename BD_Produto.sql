CREATE TABLE Produto( --NOME, QUANTIDADE, PRECO
	cod_produto serial not null,
	nome varchar(250), -- não pode ser nulo
	quantidade int, -- não pode ser negativa
	preco float, -- não pode ser negativo
	constraint priProd primary key(cod_produto)
);

--==================================== TRIGGER'S ==========================================--
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
--INSERT FUNCTION CATEGORIA; 
CREATE OR REPLACE FUNCTION Realiza_Insercao(varchar(250), int, float) RETURNS Void AS $$
BEGIN 
	INSERT INTO Visao_Produto VALUES(DEFAULT, $1, $2, $3);
END;
$$ LANGUAGE 'plpgsql';
