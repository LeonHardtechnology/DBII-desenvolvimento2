CREATE DATABASE biblioteca;

\c biblioteca

-- Tabela de Livros
CREATE TABLE Livros (
    livro_id SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    autor VARCHAR(50) NOT NULL,
    ano_publicacao INT,
    quantidade INT NOT NULL
);

-- Tabela de Membros
CREATE TABLE Membros (
    membro_id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    telefone VARCHAR(20)
);

-- Tabela de Empréstimos
CREATE TABLE Emprestimos (
    emprestimo_id SERIAL PRIMARY KEY,
    livro_id INT REFERENCES Livros(livro_id),
    membro_id INT REFERENCES Membros(membro_id),
    data_emprestimo DATE DEFAULT CURRENT_DATE,
    data_devolucao DATE
);

-- Inserir dados em Livros
INSERT INTO Livros (titulo, autor, ano_publicacao, quantidade) VALUES
('Dom Casmurro', 'Machado de Assis', 1899, 5),
('O Cortiço', 'Aluísio Azevedo', 1890, 3),
('Vidas Secas', 'Graciliano Ramos', 1938, 4);

-- Inserir dados em Membros
INSERT INTO Membros (nome, email, telefone) VALUES
('Alice Oliveira', 'alice@example.com', '123456789'),
('Bruno Souza', 'bruno@example.com', '987654321');

-- Função que será chamada pelo trigger
CREATE OR REPLACE FUNCTION atualizar_quantidade_livro()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o livro tem exemplares disponíveis
    IF (SELECT quantidade FROM Livros WHERE livro_id = NEW.livro_id) > 0 THEN
        -- Diminui a quantidade em 1 na tabela de Livros
        UPDATE Livros
        SET quantidade = quantidade - 1
        WHERE livro_id = NEW.livro_id;
        RETURN NEW;
    ELSE
        -- Lança um erro se o livro não estiver disponível
        RAISE EXCEPTION 'Livro não disponível para empréstimo';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Trigger para atualizar a quantidade de livros
CREATE TRIGGER trigger_atualizar_quantidade
AFTER INSERT ON Emprestimos
FOR EACH ROW
EXECUTE FUNCTION atualizar_quantidade_livro();

-- Inserir um empréstimo (livro_id = 1, membro_id = 1)
INSERT INTO Emprestimos (livro_id, membro_id) VALUES (1, 1);

-- Verificar a quantidade de livros atualizada
SELECT * FROM Livros WHERE livro_id = 1;
