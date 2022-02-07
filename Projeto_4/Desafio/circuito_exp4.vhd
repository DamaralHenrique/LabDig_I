------------------------------------------------------------------
-- Arquivo   : circuito_exp4.vhd
-- Projeto   : Experiencia 4 - Projeto de uma Unidade de Controle
------------------------------------------------------------------
-- Descricao : Descricao estrutural do circuito logico da
--             experiencia 04
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
        db_clock : out std_logic;
        db_tem_jogada : out std_logic;
		-- Sinais novos
		timeOut : out std_logic
    );
end entity;

architecture estrutural of circuito_exp4 is
    -- Sinais auxiliares (fluxo de dados)
    signal s_fimC, s_igual, s_zeraCor, s_zeraM, s_contaM, s_fimM: std_logic; -- Adição dos sinais intermediários do novo contador
    signal s_chaves, s_contagem, s_memoria, s_jogada: std_logic_vector (3 downto 0);

    -- Sinais auxiliares (unidade de controle)
    signal s_zeraC, s_contaC, s_zeraR, s_carregaR, s_jogada_feita: std_logic;
    signal s_estado: std_logic_vector (3 downto 0);
    signal s_zeraC_fd: std_logic;

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
            db_jogada          : out std_logic_vector (3 downto 0);
            --Novos sinais
            zeraM              : in std_logic;
            contaM             : in std_logic;
            fimM               : out std_logic
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
            db_estado : out std_logic_vector(3 downto 0);
            --Novos sinais
            fimM : in std_logic;
            zeraM : out std_logic;
            contaM : out std_logic;
            timeOut : out std_logic
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
        zeraC              => s_zeraCor,
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
        db_jogada          => s_jogada,
        -- Sinais novos
        zeraM              => s_zeraM,
        contaM             => s_contaM,
        fimM               => s_fimM
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
        db_estado => s_estado,
        --Sinais novos
        zeraM     => s_zeraM,
        contaM    => s_contaM,
        fimM      => s_fimM,
        timeOut   => timeOut 
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

    hex3: hexa7seg
    port map (
        hexa => s_estado,
        sseg => db_estado
    );

    s_chaves <= chaves;
	
	s_zeraCor <= s_zeraC or reset;

    db_igual <= s_igual;
    leds <= s_memoria;
    db_clock <= clock;
end architecture;
   
