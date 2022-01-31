------------------------------------------------------------------
-- Arquivo   : circuito_exp3.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
------------------------------------------------------------------
-- Descricao : Descricao estrutural do circuito logico da
--             experiencia 03
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp3 is
    port (
        clock : in std_logic;
        reset : in std_logic;
        iniciar : in std_logic;
        chaves : in std_logic_vector (3 downto 0);
        pronto : out std_logic;
        db_igual : out std_logic;
        db_iniciar : out std_logic;
        db_contagem : out std_logic_vector (6 downto 0);
        db_memoria : out std_logic_vector (6 downto 0);
        db_chaves : out std_logic_vector (6 downto 0);
        db_estado : out std_logic_vector (6 downto 0);
        db_zeraC    : out std_logic;
        db_contaC   : out std_logic;
        db_zeraR    : out std_logic;
        db_carregaR : out std_logic;
        db_fimC     : out std_logic
    );
end entity;

architecture estrutural of circuito_exp3 is
    -- Sinais auxiliares (fluxo de dados)
    signal s_fimC : std_logic; 
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
    component unidade_controle
        port ( 
            clock     : in  std_logic; 
            reset     : in  std_logic; 
            iniciar   : in  std_logic;
            fimC      : in  std_logic;
            zeraC     : out std_logic;
            contaC    : out std_logic;
            zeraR     : out std_logic;
            carregaR  : out std_logic;
            pronto    : out std_logic;
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
        zeraC              => s_zeraC or reset,
        contaC             => s_contaC,
        escreveM           => '0',
        zeraR              => s_zeraR,
        registraR          => s_carregaR,
        chaves             => chaves,
        chavesIgualMemoria => db_igual,
        fimC               => s_fimC,
        db_contagem        => s_contagem,
        db_memoria         => s_memoria,
        db_chaves          => s_chaves
    );

    uc: unidade_controle
    port map (
        clock     => clock, 
        reset     => reset, 
        iniciar   => iniciar,
        fimC      => s_fimC,
        zeraC     => s_zeraC,
        contaC    => s_contaC,
        zeraR     => s_zeraR,
        carregaR  => s_carregaR,
        pronto    => pronto,
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
    -- saidas de depuracao adicionais
    db_zeraC <= zeraC;
    db_contaC <= contaC;
    db_zeraR <= zeraR;
    db_carregaR <= carregaR;
    db_fimC <= fimC;
end architecture;
   
