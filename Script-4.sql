CREATE TABLE Categoria_Produto (
	catp_id INTEGER PRIMARY KEY AUTOINCREMENT,
	catp_nome VARCHAR(50) NOT NULL
);

CREATE TABLE Produto (
	prod_id INTEGER PRIMARY KEY AUTOINCREMENT,
	prod_nome VARCHAR(50) NOT NULL,
	prod_preco DECIMAL(10, 2) NOT NULL,
	prod_qnd_estoque INT NOT NULL,
	catp_catp_id INT,
	FOREIGN KEY (catp_catp_id) REFERENCES Categoria_Produto(catp_id)
);

CREATE TABLE Fornecedor(
	forn_id INTEGER PRIMARY KEY AUTOINCREMENT,
	forn_nome VARCHAR(50) NOT NULL,
	forn_cnpj VARCHAR(20) NOT NULL UNIQUE,
	forn_telefone VARCHAR(50) NOT NULL 
);

CREATE TABLE Produto_Fornecedor(
	pf_prod_id INT,
	pf_forn_id INT,
	PRIMARY KEY(pf_prod_id, pf_forn_id),
	FOREIGN KEY (pf_prod_id) REFERENCES Produto(prod_id),
    FOREIGN KEY (pf_forn_id) REFERENCES Fornecedor(forn_id)
);

CREATE TABLE Cliente(
	cli_id INTEGER PRIMARY KEY AUTOINCREMENT,
	cli_nome VARCHAR(50) NOT NULL,
	cli_cpf VARCHAR(50) NOT NULL UNIQUE,
	cli_telefone  VARCHAR(50) NOT NULL
);
 
CREATE TABLE Funcionario(
	func_id INTEGER PRIMARY KEY AUTOINCREMENT,
	func_nome VARCHAR(50) NOT NULL,
	func_cargo VARCHAR(50) NOT NULL,
	func_salario DECIMAL(10, 2) NOT NULL,
	func_data_admissao DATE NOT NULL
);

CREATE TABLE Endereco_Cliente(
	endc_id INTEGER PRIMARY KEY AUTOINCREMENT,
	endc_rua VARCHAR(100) NOT NULL,
	endc_numero VARCHAR(10) NOT NULL,
	endc_bairro VARCHAR(50) NOT NULL,
	endc_cidade VARCHAR(50) NOT NULL,
	endc_estado VARCHAR(50) NOT NULL,
	endc_cli_id INT,
	FOREIGN KEY (endc_cli_id) REFERENCES Cliente(cli_id)
);

CREATE TABLE Venda(
	venda_id INTEGER PRIMARY KEY AUTOINCREMENT,	
	venda_data DATE NOT NULL,
	venda_valor_total DECIMAL(10, 2) NOT NULL, 
	venda_cli_id INT,
	venda_func_id INT,
	FOREIGN KEY (venda_cli_id) REFERENCES Cliente(cli_id),
    FOREIGN KEY (venda_func_id) REFERENCES Funcionario(func_id)
);

CREATE TABLE Item_Venda(
	itemv_id INTEGER PRIMARY KEY AUTOINCREMENT,
	itemv_qtd INT NOT NULL,
	itemv_preco_unit DECIMAL(10, 2) NOT NULL,
	itemv_venda_id INT,
	itemv_prod_id INT,
	FOREIGN KEY (itemv_venda_id) REFERENCES Venda(venda_id),
    FOREIGN KEY (itemv_prod_id) REFERENCES Produto(prod_id)
);

CREATE TABLE Compra(
	comp_id INTEGER PRIMARY KEY AUTOINCREMENT,
	comp_data DATE NOT NULL,
	comp_valor_total DECIMAL(10, 2) NOT NULL,
	comp_forn_id INT,
	comp_func_id INT,
	FOREIGN KEY (comp_forn_id) REFERENCES Fornecedor(forn_id),
    FOREIGN KEY (comp_func_id) REFERENCES Funcionario(func_id)
);

CREATE TABLE Item_Compra(
	itemc_id INTEGER PRIMARY KEY AUTOINCREMENT,
	itemc_qtd INT NOT NULL,
	itemc_preco_unit DECIMAL(10, 2) NOT NULL,
	itemc_comp_id INT,
	itemc_prod_id INT,
	FOREIGN KEY (itemc_comp_id) REFERENCES Compra(comp_id),
    FOREIGN KEY (itemc_prod_id) REFERENCES Produto(prod_id)
);

CREATE TABLE Setor(
	setor_id INTEGER PRIMARY KEY AUTOINCREMENT,
	setor_nome VARCHAR(50) NOT NULL
);

CREATE TABLE Funcionario_Setor(
	fs_func_id INT,
	fs_setor_id INT,
	fs_data_inicio DATE NOT NULL,
	fs_data_fim DATE,
	PRIMARY KEY(fs_func_id, fs_setor_id),
	FOREIGN KEY (fs_func_id) REFERENCES Funcionario(func_id),
    FOREIGN KEY (fs_setor_id) REFERENCES Setor(setor_id)
);

CREATE TABLE Pagamento(
	pag_id INTEGER PRIMARY KEY AUTOINCREMENT,
	pag_metodo VARCHAR(50) NOT NULL,
	pag_valor DECIMAL(10, 2) NOT NULL,
	pag_data DATE NOT NULL,
	pag_venda_id INT,
	FOREIGN KEY (pag_venda_id) REFERENCES Venda(venda_id)
);

CREATE TABLE Promocao(
	promo_id INTEGER PRIMARY KEY AUTOINCREMENT,
	promo_percentual DECIMAL(10, 2) NOT NULL,
	promo_inicio DATE NOT NULL,
	promo_fim DATE,
	promo_prod_id INT,
	FOREIGN KEY (promo_prod_id) REFERENCES Produto(prod_id)
);


CREATE VIEW Media_Salarial_por_Setor_e_de_funcionários AS
WITH MediaSalarial AS (
   SELECT s.setor_id, s.setor_nome, AVG(f.func_salario) AS media_setor
   FROM Funcionario f
   JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
   JOIN Setor s ON s.setor_id = fs.fs_setor_id
   GROUP BY s.setor_id, s.setor_nome
)
SELECT ms.setor_nome AS "Nome do Setor", f.func_nome AS "Nome do Funcionário", f.func_salario AS "Salário do Funcionário", ms.media_setor AS "Média Salarial do Setor"
FROM Funcionario f
JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
JOIN MediaSalarial ms ON fs.fs_setor_id = ms.setor_id
ORDER BY ms.setor_nome ASC, f.func_salario DESC
;

-- Média salarial por setor a fim de verificar gastos com funcionários e quem recebe mais que a média

WITH MediaSalarial AS (
   SELECT
       s.setor_id,
       s.setor_nome,
       AVG(f.func_salario) AS media_setor
   FROM Funcionario f
   JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
   JOIN Setor s ON s.setor_id = fs.fs_setor_id
   GROUP BY s.setor_id, s.setor_nome
)
SELECT
   ms.setor_nome AS "Nome do Setor",
   f.func_nome AS "Nome do Funcionário",
   f.func_salario AS "Salário do Funcionário",
   ms.media_setor AS "Média Salarial do Setor"
FROM Funcionario f
JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
JOIN MediaSalarial ms ON fs.fs_setor_id = ms.setor_id
WHERE f.func_salario > ms.media_setor
ORDER BY ms.setor_nome ASC, f.func_salario DESC
;

-- Fornecedores mais requisitados em ordem decrescente
CREATE VIEW Fornecedores_Mais_Importantes AS
WITH FornecedorResumo AS (
   SELECT
       f.forn_id,
       f.forn_nome AS "Fornecedor",
       COUNT(DISTINCT c.comp_id) AS "Total de Compras",
       SUM(ic.itemc_qtd) AS "Total de Itens Comprados",
       SUM(ic.itemc_qtd * ic.itemc_preco_unit) AS "Valor Total Gasto"
   FROM Fornecedor f
   JOIN Compra c ON c.comp_forn_id = f.forn_id
   JOIN Item_Compra ic ON ic.itemc_comp_id = c.comp_id
   GROUP BY f.forn_id, f.forn_nome
)
SELECT Fornecedor, "Total de Compras", "Total de Itens Comprados", "Valor Total Gasto"
FROM FornecedorResumo
ORDER BY "Valor Total Gasto" DESC
LIMIT 5
;

-- Possiveís produtos para aplicar promoções já que saem pouco
CREATE VIEW 'Produtos para aplicar promoção' AS
SELECT p.prod_id AS "ID do Produto", p.prod_nome AS "Nome do Produto", SUM(iv.itemv_qtd) AS "Total Vendido", p.prod_qnd_estoque AS "Estoque Atual"
FROM Produto p
JOIN Item_Venda iv ON p.prod_id = iv.itemv_prod_id
WHERE "Estoque Atual" > 1000
GROUP BY "ID do Produto", "Nome do Produto"
ORDER BY "Total Vendido" ASC, "Nome do Produto" ASC
;

CREATE VIEW Produtos_para_promocao AS
SELECT p.prod_id AS "ID do Produto", p.prod_nome AS "Nome do Produto", SUM(iv.itemv_qtd) AS "Total Vendido", p.prod_qnd_estoque AS "Estoque Atual"
FROM Produto p
JOIN Item_Venda iv ON p.prod_id = iv.itemv_prod_id
WHERE "Estoque Atual" > 1000
GROUP BY "ID do Produto", "Nome do Produto"
ORDER BY "Total Vendido" ASC, "Nome do Produto" ASC
;


SELECT f.func_nome AS "Funcionário", SUM(v.venda_valor_total) AS "Total em Vendas"
FROM Funcionario f
JOIN Venda v ON v.venda_func_id = f.func_id
GROUP BY f.func_id, f.func_nome
HAVING SUM(v.venda_valor_total) < (
    SELECT AVG(total_vendas)
    FROM (
        SELECT SUM(v2.venda_valor_total) AS total_vendas
        FROM Venda v2
        GROUP BY v2.venda_func_id
    )
);

CREATE VIEW Baixa_Performance_Trimestral AS
WITH temp1 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Outubro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp2 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Setembro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp3 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Agosto", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC)
SELECT "Vendas em Agosto", "Vendas em Setembro", "Vendas em Outubro", f.func_id AS "ID do funcionário", f.func_nome AS "Nome do funcionário", ("Vendas em Agosto" + "Vendas em Setembro" + "Vendas em Outubro")/3 AS "Media Ultimo 3 Meses"
FROM Funcionario f 
LEFT JOIN temp3 ON f.func_id = temp3.venda_func_id 
LEFT JOIN temp2 ON f.func_id = temp2.venda_func_id 
LEFT JOIN temp1 ON f.func_id = temp1.venda_func_id 
WHERE "Media Ultimo 3 Meses" IS NOT NULL
ORDER BY "Media Ultimo 3 Meses" ASC
;

CREATE VIEW Alta_Performance_Trimestral AS
WITH temp1 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Outubro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp2 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Setembro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp3 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Agosto", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC)
SELECT "Vendas em Agosto", "Vendas em Setembro", "Vendas em Outubro", f.func_id AS "ID do funcionário", f.func_nome AS "Nome do funcionário", ("Vendas em Agosto" + "Vendas em Setembro" + "Vendas em Outubro")/3 AS "Media Ultimo 3 Meses"
FROM Funcionario f 
LEFT JOIN temp3 ON f.func_id = temp3.venda_func_id 
LEFT JOIN temp2 ON f.func_id = temp2.venda_func_id 
LEFT JOIN temp1 ON f.func_id = temp1.venda_func_id 
WHERE "Media Ultimo 3 Meses" IS NOT NULL
ORDER BY "Media Ultimo 3 Meses" DESC
;







WITH temp1 AS (
    -- Vendas de Outubro
    SELECT SUM(v.venda_valor_total) AS "Vendas em Outubro", v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
    GROUP BY v.venda_func_id
),
temp2 AS (
    -- Vendas de Setembro
    SELECT SUM(v.venda_valor_total) AS "Vendas em Setembro", v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-30'
    GROUP BY v.venda_func_id
),
temp3 AS (
    -- Vendas de Agosto
    SELECT SUM(v.venda_valor_total) AS "Vendas em Agosto", v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
    GROUP BY v.venda_func_id
)
SELECT 
    f.func_id AS "ID do funcionário", 
    f.func_nome AS "Nome do funcionário",
    T3."Vendas em Agosto",
    T2."Vendas em Setembro",
    T1."Vendas em Outubro",
    f.func_cargo 
FROM 
    Funcionario f 
LEFT JOIN temp3 T3 ON f.func_id = T3.venda_func_id 
LEFT JOIN temp2 T2 ON f.func_id = T2.venda_func_id 
LEFT JOIN temp1 T1 ON f.func_id = T1.venda_func_id 
ORDER BY 
    -- 1. Ordena do menor para o maior (piores) pelas vendas de Outubro. NULLs vêm primeiro.
    T1."Vendas em Outubro" ASC, 
    -- 2. Desempate por Setembro.
    T2."Vendas em Setembro" ASC,
    -- 3. Desempate por Agosto.
    T3."Vendas em Agosto" ASC
-- Limita o resultado aos 10 piores
LIMIT 10;


CREATE VIEW Valor_Vendas_Mensais_2024 AS
SELECT strftime('%Y-%m', venda_data) AS Mes_Ano, SUM(venda_valor_total) AS Valor_Vendas_Totais
FROM Venda
WHERE venda_data BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY Mes_Ano
ORDER BY Mes_Ano;


CREATE VIEW Quantidade_Vendas_Mensais AS
SELECT strftime('%Y-%m', venda_data ) AS Mes_Ano, COUNT(venda_id) AS Qntd_Vendas_Totais
FROM Venda v 
WHERE venda_data BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY Mes_Ano
ORDER BY Mes_Ano;

SELECT c.cli_nome AS Nome_Do_Cliente, c.cli_id AS ID_Do_Cliente, SUM(v.venda_valor_total) AS Valor_Total_Gasto_Pelo_Cliente
FROM Cliente c 
JOIN Venda v ON v.venda_cli_id = c.cli_id 
WHERE v.venda_data BETWEEN '2025-01-01' AND '2025-11-13'
GROUP BY ID_Do_Cliente 
ORDER BY Valor_Total_Gasto_Pelo_Cliente DESC
LIMIT 100
;

CREATE VIEW Sorteio_Melhores_Clientes AS
SELECT c.cli_nome AS Nome_Do_Cliente, c.cli_id AS ID_Do_Cliente, SUM(v.venda_valor_total) AS Valor_Total_Gasto_Pelo_Cliente
FROM Cliente c 
JOIN Venda v ON v.venda_cli_id = c.cli_id 
WHERE v.venda_data BETWEEN '2025-01-01' AND '2025-11-13'
GROUP BY ID_Do_Cliente 
ORDER BY Valor_Total_Gasto_Pelo_Cliente DESC
LIMIT 100
;

CREATE VIEW Venda_Por_Categoria AS
SELECT cp.catp_nome AS Categoria_Do_Produto, SUM(iv.itemv_qtd) AS Qntd_Vendida_Total
FROM Item_Venda iv 
JOIN Venda v ON iv.itemv_venda_id = v.venda_id 
JOIN Produto p ON iv.itemv_prod_id = p.prod_id 
JOIN Categoria_Produto cp ON cp.catp_id = p.prod_catp_id
WHERE v.venda_data BETWEEN '2025-01-01' AND '2025-11-13'
GROUP BY Categoria_Do_Produto
ORDER BY Qntd_Vendida_Total DESC
;


SELECT cp.catp_nome AS Categoria_Do_Produto, SUM(iv.itemv_qtd) AS Qntd_Vendida_Total
FROM Item_Venda iv 
JOIN Venda v ON iv.itemv_venda_id = v.venda_id 
JOIN Produto p ON iv.itemv_prod_id = p.prod_id 
JOIN Categoria_Produto cp ON cp.catp_id = p.prod_catp_id
WHERE v.venda_data BETWEEN '2025-01-01' AND '2025-11-13'
GROUP BY Categoria_Do_Produto
ORDER BY Qntd_Vendida_Total DESC
;


WITH temp1 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Outubro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp2 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Setembro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp3 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Agosto", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC)
SELECT "Vendas em Agosto", "Vendas em Setembro", "Vendas em Outubro", f.func_id AS "ID do funcionário", f.func_nome AS "Nome do funcionário", ("Vendas em Agosto" + "Vendas em Setembro" + "Vendas em Outubro")/3 AS "Media Ultimo 3 Meses"
FROM Funcionario f 
LEFT JOIN temp3 ON f.func_id = temp3.venda_func_id 
LEFT JOIN temp2 ON f.func_id = temp2.venda_func_id 
LEFT JOIN temp1 ON f.func_id = temp1.venda_func_id 
WHERE "Media Ultimo 3 Meses" IS NOT NULL
ORDER BY "Media Ultimo 3 Meses" ASC
;

WITH MediaSalarial AS (
   SELECT
       s.setor_id,
       s.setor_nome,
       AVG(f.func_salario) AS media_setor
   FROM Funcionario f
   JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
   JOIN Setor s ON s.setor_id = fs.fs_setor_id
   GROUP BY s.setor_id, s.setor_nome
),
temp1 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Outubro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp2 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Setembro", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC),
temp3 AS(
SELECT SUM(v.venda_valor_total) AS "Vendas em Agosto", v.venda_func_id
FROM Venda v
JOIN Funcionario f ON v.venda_func_id = f.func_id 
WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
GROUP BY v.venda_func_id
ORDER BY v.venda_func_id ASC)
SELECT "Vendas em Agosto", "Vendas em Setembro", "Vendas em Outubro", f.func_id AS "ID do funcionário", 
f.func_nome AS "Nome do funcionário", ("Vendas em Agosto" + "Vendas em Setembro" + "Vendas em Outubro")/3 AS "Media Ultimo 3 Meses", s.setor_id, s.setor_nome, AVG(f.func_salario) AS media_setor
FROM Funcionario f 
LEFT JOIN temp3 ON f.func_id = temp3.venda_func_id 
LEFT JOIN temp2 ON f.func_id = temp2.venda_func_id 
LEFT JOIN temp1 ON f.func_id = temp1.venda_func_id
LEFT JOIN MediaSalarial ON MediaSalarial.setor_id = f.func_setor_id
WHERE "Media Ultimo 3 Meses" IS NOT NULL
ORDER BY "Media Ultimo 3 Meses" ASC
;



SELECT
   ms.setor_nome AS "Nome do Setor",
   f.func_nome AS "Nome do Funcionário",
   f.func_salario AS "Salário do Funcionário",
   ms.media_setor AS "Média Salarial do Setor"
FROM Funcionario f
JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
JOIN MediaSalarial ms ON fs.fs_setor_id = ms.setor_id
WHERE f.func_salario > ms.media_setor
ORDER BY ms.setor_nome ASC, f.func_salario DESC
;


SELECT
       s.setor_id,
       s.setor_nome,
       AVG(f.func_salario) AS media_setor
   FROM Funcionario f
   JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
   JOIN Setor s ON s.setor_id = fs.fs_setor_id
   GROUP BY s.setor_id, s.setor_nome;

WITH temp1 AS(
    SELECT SUM(v.venda_valor_total) AS vendas_outubro, v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
    GROUP BY v.venda_func_id
),
temp2 AS(
    SELECT SUM(v.venda_valor_total) AS vendas_setembro, v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-30'
    GROUP BY v.venda_func_id
),
temp3 AS(
    SELECT SUM(v.venda_valor_total) AS vendas_agosto, v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
    GROUP BY v.venda_func_id
),
MediaVendas AS (
    SELECT
        f.func_id,
        f.func_nome,
        COALESCE(t3.vendas_agosto,0) AS vendas_agosto,
        COALESCE(t2.vendas_setembro,0) AS vendas_setembro,
        COALESCE(t1.vendas_outubro,0) AS vendas_outubro,
        (COALESCE(t3.vendas_agosto,0) + COALESCE(t2.vendas_setembro,0) + COALESCE(t1.vendas_outubro,0)) / 3.0 
            AS media_3_meses
    FROM Funcionario f
    LEFT JOIN temp3 t3 ON f.func_id = t3.venda_func_id 
    LEFT JOIN temp2 t2 ON f.func_id = t2.venda_func_id 
    LEFT JOIN temp1 t1 ON f.func_id = t1.venda_func_id
),
MediaSalarial AS (
    SELECT
        s.setor_id,
        s.setor_nome,
        AVG(f.func_salario) AS media_setor
    FROM Funcionario f
    JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
    JOIN Setor s ON s.setor_id = fs.fs_setor_id
    GROUP BY s.setor_id, s.setor_nome
)
SELECT
    mv.func_id AS "ID Funcionário",
    mv.func_nome AS "Nome do Funcionário",
    mv.vendas_agosto AS "Vendas em Agosto",
    mv.vendas_setembro AS "Vendas em Setembro",
    mv.vendas_outubro AS "Vendas em Outubro",
    mv.media_3_meses AS "Média de Vendas (3 meses)",
    f.func_salario AS "Salário",
    ms.media_setor AS "Média Salarial do Setor",
    CASE 
        WHEN f.func_salario > ms.media_setor 
             AND mv.media_3_meses < (
                SELECT AVG(media_3_meses) FROM MediaVendas
             ) THEN '⚠ Possível falta de motivação'
        WHEN f.func_salario > ms.media_setor THEN 'Acima média salarial'
        ELSE 'Salário dentro do esperado'
    END AS "Diagnóstico"
FROM MediaVendas mv
JOIN Funcionario f ON mv.func_id = f.func_id
JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
JOIN MediaSalarial ms ON fs.fs_setor_id = ms.setor_id
ORDER BY mv.media_3_meses ASC;

CREATE VIEW Desempenho_X_SalarioSetor AS
WITH temp1 AS(
    SELECT SUM(v.venda_valor_total) AS vendas_outubro, v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-10-01' AND '2025-10-31'
    GROUP BY v.venda_func_id
),
temp2 AS(
    SELECT SUM(v.venda_valor_total) AS vendas_setembro, v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-09-01' AND '2025-09-30'
    GROUP BY v.venda_func_id
),
temp3 AS(
    SELECT SUM(v.venda_valor_total) AS vendas_agosto, v.venda_func_id
    FROM Venda v
    WHERE v.venda_data BETWEEN '2025-08-01' AND '2025-08-31'
    GROUP BY v.venda_func_id
),
MediaVendas AS (
    SELECT
        f.func_id,
        f.func_nome,
        t3.vendas_agosto,
        t2.vendas_setembro,
        t1.vendas_outubro,
        (t3.vendas_agosto + t2.vendas_setembro + t1.vendas_outubro) / 3.0 AS media_3_meses
    FROM Funcionario f
    LEFT JOIN temp3 t3 ON f.func_id = t3.venda_func_id 
    LEFT JOIN temp2 t2 ON f.func_id = t2.venda_func_id 
    LEFT JOIN temp1 t1 ON f.func_id = t1.venda_func_id
    -- Exclui quem tiver algum mês NULL ou igual a 0
    WHERE t3.vendas_agosto IS NOT NULL AND t3.vendas_agosto > 0
      AND t2.vendas_setembro IS NOT NULL AND t2.vendas_setembro > 0
      AND t1.vendas_outubro IS NOT NULL AND t1.vendas_outubro > 0
),
MediaSalarial AS (
    SELECT
        s.setor_id,
        s.setor_nome,
        AVG(f.func_salario) AS media_setor
    FROM Funcionario f
    JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
    JOIN Setor s ON s.setor_id = fs.fs_setor_id
    GROUP BY s.setor_id, s.setor_nome
),
Piores10 AS (
    SELECT *
    FROM MediaVendas
    ORDER BY media_3_meses ASC
    LIMIT 10
)
SELECT
    p.func_id               AS "ID Funcionário",
    p.func_nome             AS "Nome do Funcionário",
    p.vendas_agosto         AS "Vendas Agosto",
    p.vendas_setembro      AS "Vendas Setembro",
    p.vendas_outubro        AS "Vendas Outubro",
    p.media_3_meses         AS "Média Trimestral",
    f.func_salario          AS "Salário",
    ms.media_setor          AS "Média Salarial do Setor"
FROM Piores10 p
JOIN Funcionario f ON p.func_id = f.func_id
JOIN Funcionario_Setor fs ON f.func_id = fs.fs_func_id
JOIN MediaSalarial ms ON fs.fs_setor_id = ms.setor_id
ORDER BY p.media_3_meses ASC;

SELECT 
    f.forn_nome AS "Fornecedor",
    p.prod_nome AS "Produto",
    SUM(ic.itemc_qtd * ic.itemc_preco_unit) AS "Total Gasto no Produto"
FROM Item_Compra ic
JOIN Compra c ON ic.itemc_comp_id = c.comp_id
JOIN Fornecedor f ON c.comp_forn_id = f.forn_id
JOIN Produto p ON ic.itemc_prod_id = p.prod_id
WHERE f.forn_id = 68
GROUP BY f.forn_nome, p.prod_nome
ORDER BY "Total Gasto no Produto" DESC;

SELECT
    p.prod_id AS "ID do Produto",
    p.prod_nome AS "Produto",
    SUM(ic.itemc_qtd) AS "Quantidade Total Comprada",
    SUM(ic.itemc_qtd * ic.itemc_preco_unit) AS "Valor Total Gasto"
FROM Item_Compra ic
JOIN Compra c ON ic.itemc_comp_id = c.comp_id
JOIN Fornecedor f ON c.comp_forn_id = f.forn_id
JOIN Produto p ON ic.itemc_prod_id = p.prod_id
WHERE f.forn_id = 68
GROUP BY p.prod_id, p.prod_nome
ORDER BY "Quantidade Total Comprada" DESC;


SELECT 
    f.forn_id AS ID_Fornecedor,
    f.forn_nome AS Nome_Fornecedor,
    SUM(iv.itemv_qtd) AS Total_Itens_Vendidos
FROM Item_Venda iv
JOIN Produto p ON iv.itemv_prod_id = p.prod_id
JOIN Produto_Fornecedor pf ON p.prod_id = pf.pf_prod_id
JOIN Fornecedor f ON pf.pf_forn_id = f.forn_id
GROUP BY f.forn_id, f.forn_nome
ORDER BY Total_Itens_Vendidos DESC;

SELECT 
    f.forn_id AS ID_Fornecedor,
    f.forn_nome AS Nome_Fornecedor,
    SUM(iv.itemv_qtd) AS Total_Itens_Vendidos,
    SUM(iv.itemv_qtd * iv.itemv_preco_unit) AS Total_Valor_Vendido
FROM Item_Venda iv
JOIN Produto p 
    ON iv.itemv_prod_id = p.prod_id
JOIN Produto_Fornecedor pf 
    ON p.prod_id = pf.pf_prod_id
JOIN Fornecedor f 
    ON pf.pf_forn_id = f.forn_id
GROUP BY 
    f.forn_id, f.forn_nome
ORDER BY 
    Total_Valor_Vendido DESC;

WITH Ranking AS (
    SELECT
        f.forn_id AS ID_Fornecedor,
        f.forn_nome AS Nome_Fornecedor,
        SUM(iv.itemv_qtd * iv.itemv_preco_unit) AS Total_Valor_Vendido
    FROM Item_Venda iv
    JOIN Produto p 
        ON iv.itemv_prod_id = p.prod_id
    JOIN Produto_Fornecedor pf 
        ON p.prod_id = pf.pf_prod_id
    JOIN Fornecedor f 
        ON pf.pf_forn_id = f.forn_id
    GROUP BY 
        f.forn_id, f.forn_nome
    ORDER BY 
        Total_Valor_Vendido DESC
)
SELECT 
    ID_Fornecedor,
    Nome_Fornecedor,
    Total_Valor_Vendido,
    (SELECT COUNT(*) 
     FROM Ranking r2 
     WHERE r2.Total_Valor_Vendido > Ranking.Total_Valor_Vendido) + 1
        AS Posicao_no_Ranking
FROM Ranking
WHERE ID_Fornecedor = 68;

SELECT 
    f.forn_id,
    f.forn_nome,
    SUM(ic.itemc_qtd * ic.itemc_preco_unit) AS Total_Comprado
FROM Item_Compra ic
JOIN Compra c ON ic.itemc_comp_id = c.comp_id
JOIN Fornecedor f ON c.comp_forn_id = f.forn_id
GROUP BY f.forn_id, f.forn_nome
ORDER BY Total_Comprado DESC;



SELECT 
    f.forn_id,
    f.forn_nome,
    SUM(iv.itemv_qtd * iv.itemv_preco_unit) AS Total_Vendido
FROM Item_Venda iv
JOIN Produto p ON iv.itemv_prod_id = p.prod_id
JOIN Produto_Fornecedor pf ON p.prod_id = pf.pf_prod_id
JOIN Fornecedor f ON pf.pf_forn_id = f.forn_id
GROUP BY f.forn_id, f.forn_nome
ORDER BY Total_Vendido DESC
;



WITH 
Vendas AS (
    SELECT 
        f.forn_id,
        f.forn_nome,
        SUM(iv.itemv_qtd * iv.itemv_preco_unit) AS Total_Vendido
    FROM Item_Venda iv
    JOIN Produto p ON iv.itemv_prod_id = p.prod_id
    JOIN Produto_Fornecedor pf ON p.prod_id = pf.pf_prod_id
    JOIN Fornecedor f ON pf.pf_forn_id = f.forn_id
    GROUP BY f.forn_id, f.forn_nome
),
Compras AS (
    SELECT
        f.forn_id,
        SUM(ic.itemc_qtd * ic.itemc_preco_unit) AS Total_Gasto
    FROM Fornecedor f
    JOIN Compra c ON c.comp_forn_id = f.forn_id
    JOIN Item_Compra ic ON ic.itemc_comp_id = c.comp_id
    GROUP BY f.forn_id
),
Top5 AS (
    SELECT forn_id
    FROM Vendas
    WHERE forn_id <> 68
    ORDER BY Total_Vendido DESC
    LIMIT 5
),
Final AS (
    SELECT 
        v.forn_id,
        v.forn_nome,
        c.Total_Gasto,
        v.Total_Vendido
    FROM Vendas v
    JOIN Compras c ON v.forn_id = c.forn_id
    WHERE v.forn_id = 68
       OR v.forn_id IN (SELECT forn_id FROM Top5)
)
SELECT *
FROM Final
ORDER BY Total_Vendido DESC;

CREATE VIEW Produtos_Dos_Fornecedores_Vendidos_Para_Clientes AS
SELECT 
    f.forn_id,
    f.forn_nome,
    SUM(iv.itemv_qtd * iv.itemv_preco_unit) AS Total_Vendido
FROM Item_Venda iv
JOIN Produto p 
    ON iv.itemv_prod_id = p.prod_id
JOIN Produto_Fornecedor pf 
    ON p.prod_id = pf.pf_prod_id
JOIN Fornecedor f 
    ON pf.pf_forn_id = f.forn_id
GROUP BY 
    f.forn_id, 
    f.forn_nome
ORDER BY 
    Total_Vendido DESC;

CREATE VIEW VIEW_FLUXO_SETOR_CARGO AS
SELECT
    S.setor_nome AS Origem_Setor,
    F.func_cargo AS Destino_Cargo,
    COUNT(F.func_id) AS Contagem_Funcionarios
FROM
    Funcionario AS F
JOIN
    Funcionario_Setor AS FS ON F.func_id = FS.fs_func_id
JOIN
    Setor AS S ON FS.fs_setor_id = S.setor_id
GROUP BY
    S.setor_nome, F.func_cargo
ORDER BY
    S.setor_nome, Contagem_Funcionarios DESC;

CREATE VIEW Endereco_De_Clientes AS
SELECT
    EC.endc_estado AS Estado,
    SUM(V.venda_valor_total) AS Total_Arrecadado
FROM
    Endereco_Cliente AS EC
JOIN
    Cliente AS C ON EC.endc_cli_id = C.cli_id
JOIN
    Venda AS V ON C.cli_id = V.venda_cli_id
GROUP BY
    EC.endc_estado
ORDER BY
    Total_Arrecadado DESC;


CREATE VIEW Endereco_De_Clientes_ISO AS
SELECT
    'BR-' || EC.endc_estado AS Estado_ISO, -- O operador '||' concatena strings no SQLite
    SUM(V.venda_valor_total) AS Total_Arrecadado
FROM
    Endereco_Cliente AS EC
JOIN
    Cliente AS C ON EC.endc_cli_id = C.cli_id
JOIN
    Venda AS V ON C.cli_id = V.venda_cli_id
GROUP BY
    EC.endc_estado
ORDER BY
    Total_Arrecadado DESC;







