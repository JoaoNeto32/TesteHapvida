-- pkg_cliente_body.sql

CREATE OR REPLACE PACKAGE BODY PKG_CLIENTE AS

    FUNCTION FN_VALIDAR_EMAIL(p_email VARCHAR2) RETURN NUMBER IS
    BEGIN
        IF REGEXP_LIKE(p_email, '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$', 'i') THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END;

    FUNCTION FN_NORMALIZAR_CEP(p_cep VARCHAR2) RETURN VARCHAR2 IS
        v_cep VARCHAR2(8);
    BEGIN
        v_cep := REGEXP_REPLACE(p_cep, '[^0-9]', '');
        IF LENGTH(v_cep) = 8 THEN
            RETURN v_cep;
        ELSE
            RETURN NULL;  
        END IF;
    END;

    PROCEDURE VALIDAR_DADOS_COMUNS(
        p_nome VARCHAR2,
        p_email VARCHAR2,
        p_cep VARCHAR2,
        p_uf CHAR,
        p_ativo NUMBER
    ) IS
        v_cep_norm VARCHAR2(8);
    BEGIN
        IF p_nome IS NULL OR TRIM(p_nome) = '' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Nome é obrigatório.');
        END IF;

        IF p_email IS NULL OR FN_VALIDAR_EMAIL(p_email) = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email inválido.');
        END IF;

        IF p_cep IS NOT NULL THEN
            v_cep_norm := FN_NORMALIZAR_CEP(p_cep);
            IF v_cep_norm IS NULL THEN
                RAISE_APPLICATION_ERROR(-20001, 'CEP deve ter exatamente 8 dígitos.');
            END IF;
        END IF;

        IF p_uf IS NOT NULL AND NOT (p_uf IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')) THEN
            RAISE_APPLICATION_ERROR(-20001, 'UF inválida.');
        END IF;

        IF p_ativo NOT IN (0, 1) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Ativo deve ser 0 ou 1.');
        END IF;
    END;

    PROCEDURE PRC_INSERIR_CLIENTE(
        p_nome VARCHAR2,
        p_email VARCHAR2,
        p_cep VARCHAR2,
        p_logradouro VARCHAR2,
        p_bairro VARCHAR2,
        p_cidade VARCHAR2,
        p_uf CHAR,
        p_ativo NUMBER,
        p_id OUT NUMBER
    ) IS
        v_cep_norm VARCHAR2(8) := FN_NORMALIZAR_CEP(p_cep);
    BEGIN
        VALIDAR_DADOS_COMUNS(p_nome, p_email, v_cep_norm, p_uf, p_ativo);

        INSERT INTO TB_CLIENTE (NOME, EMAIL, CEP, LOGRADOURO, BAIRRO, CIDADE, UF, ATIVO)
        VALUES (p_nome, p_email, v_cep_norm, p_logradouro, p_bairro, p_cidade, p_uf, p_ativo)
        RETURNING ID_CLIENTE INTO p_id;

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20002, 'Email já existe (violação de unicidade).');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erro na inserção: ' || SQLERRM);
    END;

    PROCEDURE PRC_ATUALIZAR_CLIENTE(
        p_id NUMBER,
        p_nome VARCHAR2,
        p_email VARCHAR2,
        p_cep VARCHAR2,
        p_logradouro VARCHAR2,
        p_bairro VARCHAR2,
        p_cidade VARCHAR2,
        p_uf CHAR,
        p_ativo NUMBER
    ) IS
        v_cep_norm VARCHAR2(8) := FN_NORMALIZAR_CEP(p_cep);
    BEGIN
        VALIDAR_DADOS_COMUNS(p_nome, p_email, v_cep_norm, p_uf, p_ativo);

        UPDATE TB_CLIENTE
        SET NOME = p_nome,
            EMAIL = p_email,
            CEP = v_cep_norm,
            LOGRADOURO = p_logradouro,
            BAIRRO = p_bairro,
            CIDADE = p_cidade,
            UF = p_uf,
            ATIVO = p_ativo
        WHERE ID_CLIENTE = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Registro não encontrado.');
        END IF;

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20002, 'Email já existe (violação de unicidade).');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erro na atualização: ' || SQLERRM);
    END;

    PROCEDURE PRC_DELETAR_CLIENTE(p_id NUMBER) IS
    BEGIN
        DELETE FROM TB_CLIENTE WHERE ID_CLIENTE = p_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Registro não encontrado.');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erro na exclusão: ' || SQLERRM);
    END;

    PROCEDURE PRC_LISTAR_CLIENTES(
        p_nome VARCHAR2,
        p_email VARCHAR2,
        p_rc OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_rc FOR
        SELECT * FROM TB_CLIENTE
        WHERE (p_nome IS NULL OR NOME LIKE '%' || p_nome || '%')
        AND (p_email IS NULL OR EMAIL LIKE '%' || p_email || '%');
    END;

END PKG_CLIENTE;

/
