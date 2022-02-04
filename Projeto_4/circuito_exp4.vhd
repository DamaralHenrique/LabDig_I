------------------------------------------------------------------
-- Arquivo   : circuito_exp3.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
------------------------------------------------------------------
-- Descricao : Descricao estrutural do circuito logico da
--             experiencia 03
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp4 is
    port (      
        clock : in std_logic;
        reset : in std_logic;
        iniciar : in std_logic;
        chaves : in std_logic_vector (3 downto 0);
        pronto : out std_logic;
        acertou : out std_logic;
        errou : out std_logic;
        leds : out std_logic_vector (3 downto 0);
        db_igual : out std_logic;
        db_contagem : out std_logic_vector (6 downto 0);
        db_memoria : out std_logic_vector (6 downto 0);
        db_estado : out std_logic_vector (6 downto 0);
        db_jogadafeita : out std_logic_vector (6 downto 0);
        db_chaves : out std_logic_vector (6 downto 0);
        db_clock : out std_logic;
        db_tem_jogada : out std_logic;
        -- Sinais extras de depuração
        db_zeraC    : out std_logic;
        db_contaC   : out std_logic;
        db_zeraR    : out std_logic;
        db_carregaR : out std_logic;
        db_fimC     : out std_logic

    );
end entity;

architecture estrutural of circuito_exp4 is
    -- Sinais auxiliares (fluxo de dados)
    signal s_fimC, s_igual : std_logic; 
    signal s_chaves, s_contagem, s_memoria, s_jogada: std_logic_vector (3 downto 0);

    -- Sinais auxiliares (unidade de controle)
    signal s_zeraC, s_contaC, s_zeraR, s_carregaR, s_jogada_feita: std_logic;
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
            igual              : out std_logic;
            fimC               : out std_logic;
            jogada_feita       : out std_logic;
            db_tem_jogada      : out std_logic;
            db_contagem        : out std_logic_vector (3 downto 0);
            db_memoria         : out std_logic_vector (3 downto 0);
            db_jogada          : out std_logic_vector (3 downto 0)
        );
    end component;

    -- Unidade de controle
    component unidade_controle
        port ( 
            clock     : in  std_logic; 
            reset     : in  std_logic; 
            iniciar   : in  std_logic;
            fimC      : in  std_logic;
            jogada    : in  std_logic;
            igual     : in  std_logic;
            zeraC     : out std_logic;
            contaC    : out std_logic;
            zeraR     : out std_logic;
            carregaR  : out std_logic;
            pronto    : out std_logic;
            acertou   : out std_logic;
            errou     : out std_logic;
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
        igual              => s_igual,
        fimC               => s_fimC,
        jogada_feita       => s_jogada_feita, 
        db_tem_jogada      => db_tem_jogada,
        db_contagem        => s_contagem,
        db_memoria         => s_memoria,
        db_jogada          => s_jogada
    );

    uc: unidade_controle
    port map (
        clock     => clock, 
        reset     => reset, 
        iniciar   => iniciar,
        fimC      => s_fimC,
        jogada    => s_jogada_feita,
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

    hex2: hexa7seg
    port map (
        hexa => s_jogada,
        sseg => db_jogadafeita
    );

    hex4: hexa7seg
    port map (
        hexa => s_chaves,
        sseg => db_chaves
    );

    hex5: hexa7seg
    port map (
        hexa => s_estado,
        sseg => db_estado
    );

    db_igual <= s_igual;
    leds <= s_memoria;
    db_clock <= clock;

    -- saidas de depuracao adicionais
    db_zeraC <= s_zeraC;
    db_contaC <= s_contaC;
    db_zeraR <= s_zeraR;
    db_carregaR <= s_carregaR;
    db_fimC <= s_fimC;
end architecture;
   
