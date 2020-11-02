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
drop table compra cascade;

CREATE TABLE Item_Compra(
	cod_item_compra serial not null,
    cod_compra int not null,
    cod_produto int not null,
    quant_comprada int,
    constraint priItemC primary key(cod_item_compra),
    constraint stngItemCCompra foreign key(cod_compra) references Compra(cod_compra),
    constraint stngItemCProd foreign key(cod_produto) references Produto(cod_produto) 
);
drop table item_compra;

select * from vendedor;
select * from produto;
select * from fornecedor;
select * from produto_fornecido;
select * from compra;
select * from item_compra;

select fornecimento('razer', 'mouse', 75);
select realiza_compra('andré', 'teclado', 'razer', 15);
select realiza_compra('carlos', 'teclado', 'razer', 15);
select realiza_compra('andré', 'teclado', 10);
select realiza_compra('andré', 'mouse', 10);
select finaliza_compra(1);
select melhor_preco(1);

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

-- REALIZA COMPRA(SEM FORNECEDOR) (NOME VENDEDOR, NOME PRODUTO, QUANTIDADE)
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

'''
-- Verifica se o vendedor está vinculado com uma compra aberta.
CREATE TRIGGER Trig_Compra BEFORE INSERT or UPDATE ON Compra FOR EACH STATEMENT EXECUTE PROCEDURE Checa_Status_Vendedor();

CREATE OR REPLACE FUNCTION Checa_Status_Vendedor() RETURNS TRIGGER AS $$
DECLARE
    cod_comp int;

BEGIN
    SELECT cod_compra INTO cod_comp FROM COMPRA WHERE new.cod_vendedor in(select cod_vendedor FROM Compra WHERE status_compra = true);
    IF new.cod_vendedor in(select cod_vendedor FROM Compra WHERE status_compra = true) THEN
        RAISE EXCEPTION 'O vendedor está relacionado com uma compra de código % que não foi finalizada. Compra não afetuada.', cod_comp;
    END IF;
	RETURN NULL;
END;
$$ LANGUAGE 'plpgsql'; 
'''