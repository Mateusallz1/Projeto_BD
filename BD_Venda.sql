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

select * from venda
select * from item_venda
select * from vendedor
select * from produto
select * from cliente
select realiza_venda('andré', 'joão', 'mouse' )

--==================================== FUNCTION'S ==========================================--
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
