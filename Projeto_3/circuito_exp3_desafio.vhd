--------------------------------------------------------------------
-- Arquivo   : circuito_exp3_desafio.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
--------------------------------------------------------------------
-- Descricao : circuito do desafio da experiencia 3 
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp3_desafio is
    port (
        clock : in std_logic;
        reset : in std_logic;
        iniciar : in std_logic;
        chaves : in std_logic_vector (3 downto 0);
        pronto : out std_logic;
        acertou : out std_logic; -- Sinal que indica que todos os dados da memoria foram acertados
        errou : out std_logic; -- Sinal que indica que ao menos um dado da memoria foi errado
        db_igual : out std_logic;
        db_iniciar : out std_logic;
        db_contagem : out std_logic_vector (6 downto 0);
        db_memoria : out std_logic_vector (6 downto 0);
        db_chaves : out std_logic_vector (6 downto 0);
        db_estado : out std_logic_vector (6 downto 0)
     );
end entity;

architecture estrutural of circuito_exp3_desafio is
    -- Sinais auxiliares (fluxo de dados)
    signal s_fimC, s_igual: std_logic; -- Novo sinal auxiliar "s_igual" para usar no port map da nova UC
    signal s_chaves, s_contagem, s_memoria: std_logic_vector (3 downto 0);

    -- Sinais auxiliares (unidade de controle)
    signal s_zeraC, s_contaC, s_zeraR, s_carregaR: std_logic;
    signal s_estado: std_logic_vector (3 downto 0);

    -- Fluxo de dados
    component fluxo_dados
        port (
            clock              : in  std_logic;
            zeraC              : in  std_logic;
            contaC             : in  std_logic;
            escreveM           : in  std_logic;
            zeraR              : in  std_logic;
            registraR          : in  std_logic;
            chaves             : in  std_logic_vector (3 downto 0);
            chavesIgualMemoria : out std_logic;
            fimC               : out std_logic;
            db_contagem        : out std_logic_vector (3 downto 0);
            db_memoria         : out std_logic_vector (3 downto 0);
            db_chaves          : out std_logic_vector (3 downto 0)
        );
    end component;

    -- Unidade de controle
    component unidade_controle_desafio
        port ( 
            clock     : in  std_logic; 
            reset     : in  std_logic; 
            iniciar   : in  std_logic;
            fimC      : in  std_logic;
            igual     : in  std_logic; -- Sinal que indica que os dados comparados sao iguais
            zeraC     : out std_logic;
            contaC    : out std_logic;
            zeraR     : out std_logic;
            carregaR  : out std_logic;
            pronto    : out std_logic;
            acertou   : out std_logic; -- Sinal que indica que todos os dados da memoria foram acertados
            errou     : out std_logic; -- Sinal que indica que ao menos um dado da memoria foi errado
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos
    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    fd: fluxo_dados
    port map (
        clock              => clock,
        zeraC              => reset,
        contaC             => s_contaC,
        escreveM           => '0',
        zeraR              => s_zeraR,
        registraR          => s_carregaR,
        chaves             => chaves,
        chavesIgualMemoria => s_igual,
        fimC               => s_fimC,
        db_contagem        => s_contagem,
        db_memoria         => s_memoria,
        db_chaves          => s_chaves
    );

    -- Novo port map para usar a nova UC
    uc: unidade_controle_desafio
    port map (
        clock     => clock, 
        reset     => reset, 
        iniciar   => iniciar,
        fimC      => s_fimC,
        igual     => s_igual,
        zeraC     => s_zeraC,
        contaC    => s_contaC,
        zeraR     => s_zeraR,
        carregaR  => s_carregaR,
        pronto    => pronto,
        acertou   => acertou,
        errou     => errou,
        db_estado => s_estado
    );

    hex2: hexa7seg
    port map (
        hexa => s_chaves,
        sseg => db_chaves
    );

    hex0: hexa7seg
    port map (
        hexa => s_contagem,
        sseg => db_contagem
    );

    hex1: hexa7seg
    port map (
        hexa => s_memoria,
        sseg => db_memoria
    );

    hex5: hexa7seg
    port map (
        hexa => s_estado,
        sseg => db_estado
    );

    db_iniciar <= iniciar;
    db_igual <= s_igual;
end architecture;
   