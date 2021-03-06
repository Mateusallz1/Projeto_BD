CREATE TABLE Produto_Fornecido(
    cod_fornecedor int not null,
    cod_produto int not null,
    valor_unitario float,
    constraint stngFornProd foreign key(cod_produto) references Produto(cod_produto),
    constraint stngFornForn foreign key(cod_fornecedor) references Fornecedor(cod_fornecedor)
);

select fornecimento('RAZER','MAO', 100)
select fornecimento('RED DRAGON')
select * from fornecedor
select * from produto
select * from produto_fornecido

--==================================== FUNCTION PROD_FORNECIDO ========================================================--
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