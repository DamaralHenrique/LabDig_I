--------------------------------------------------------------------
-- Arquivo   : circuito_exp3_desafio_tb.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
--------------------------------------------------------------------
-- Descricao : testbench para circuito do desafio da experiencia 3 
--
--             1) plano de teste: 14 casos de teste
--------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp3_desafio_tb is
end entity;

architecture tb of circuito_exp3_desafio_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component circuito_exp3_desafio is
    port (
        clock : in std_logic;
        reset : in std_logic;
        iniciar : in std_logic;
        chaves : in std_logic_vector (3 downto 0);
        pronto : out std_logic;
        acertou : out std_logic;
        errou : out std_logic;
        db_igual : out std_logic;
        db_iniciar : out std_logic;
        db_contagem : out std_logic_vector (6 downto 0);
        db_memoria : out std_logic_vector (6 downto 0);
        db_chaves : out std_logic_vector (6 downto 0);
        db_estado : out std_logic_vector (6 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in         : std_logic := '0';
  signal reset_in         : std_logic := '0';
  signal iniciar_in       : std_logic := '0';
  signal chaves_in        : std_logic_vector (3 downto 0) := "0000";
  signal pronto_out       : std_logic := '0';
  signal acertou_out      : std_logic := '0';
  signal errou_out        : std_logic := '0';
  signal db_igual_out     : std_logic := '0';
  signal db_contagem_out  : std_logic_vector (6 downto 0) := "0000000";
  signal db_memoria_out   : std_logic_vector (6 downto 0) := "0000000";
  signal db_chaves_out    : std_logic_vector (6 downto 0) := "0000000";
  signal db_estado_out    : std_logic_vector (6 downto 0) := "0000000";

  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;
  
  -- Identificacao de casos de teste
  signal caso : integer := 0;

begin
  
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

  -- Conecta DUT (Device Under Test)
  dut: circuito_exp3_desafio 
       port map( 
           clock         =>  clock_in,
           reset         =>  reset_in,
           iniciar       =>  iniciar_in,
           chaves        =>  chaves_in,
           pronto        =>  pronto_out,
           acertou       =>  acertou_out,
           errou         =>  errou_out,
           db_igual      =>  db_igual_out,
           db_contagem   =>  db_contagem_out,
           db_memoria    =>  db_memoria_out,
           db_chaves     =>  db_chaves_out,
           db_estado     =>  db_estado_out  
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin

    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock
    
    ---- condicoes iniciais ----------------
    caso       <= 0;
    reset_in   <= '0';
    iniciar_in <= '0';
    chaves_in  <= "0000";
    wait for clockPeriod;


    ---- Teste 1 (resetar circuito)    
    caso       <= 1;
    -- gera pulso de reset
    wait until falling_edge(clock_in);
    reset_in   <= '1';
    wait for clockPeriod;
    reset_in   <= '0';


    ---- Teste 2 (iniciar=0 por 5 periodos de clock)    
    caso <= 2;
    -- espera por 5 periodos de clock
    wait for 5*clockPeriod;


    ---- Teste 3 (ajustar chaves para 0001, acionar iniciar por 1 periodo de clock)    
    caso <= 3;
    chaves_in  <= "0001";    
    -- pulso em iniciar
    wait until falling_edge(clock_in);
    iniciar_in <= '1';
    wait for clockPeriod;
    iniciar_in <= '0';


    ---- Teste 4 (ajustar chaves para 0001 por 1 periodo de clock)    
    caso <= 4;
    chaves_in  <= "0001";
    wait for clockPeriod;


    ---- Teste 5 (ajustar chaves para 0001 por 1 periodo de clock)    
    caso <= 5;
    chaves_in  <= "0001";
    wait for clockPeriod;



    ---- Teste 6 (ajustar chaves para 0001 por 1 periodo de clock)    
    caso <= 6;
    chaves_in  <= "0001";
    wait for clockPeriod;


    ---- Teste 7 (ajustar chaves para 0010 por 3 periodos de clock)    
    caso <= 7;
    chaves_in  <= "0010";
    wait for 3*clockPeriod;


    ---- Teste 8 (ajustar chaves para 0100 por 3 periodos de clock)    
    caso <= 8;
    chaves_in  <= "0100";
    wait for 3*clockPeriod;


    ---- Teste 9 (ajustar chaves para 1000 por 9 periodos de clock)    
    caso <= 9;
    chaves_in  <= "1000";
    wait for 9*clockPeriod;


    ---- Teste 10 (ajustar chaves para 0100 por 6 periodos de clock)    
    caso <= 10;
    chaves_in  <= "0100";
    wait for 6*clockPeriod;


    ---- Teste 11 (ajustar chaves para 0010 por 3 periodos de clock)    
    caso <= 11;
    chaves_in  <= "0010";
    wait for 3*clockPeriod;


    ---- Teste 12 (ajustar chaves para 0001 por 6 periodos de clock)    
    caso <= 12;
    chaves_in  <= "0001";
    wait for 6*clockPeriod;


    ---- Teste 13 (ajustar chaves para 0010 por 6 periodos de clock)    
    caso <= 13;
    chaves_in  <= "0010";
    wait for 6*clockPeriod;


    ---- Teste 14 (ajustar chaves para 0100 por 3 periodos de clock)    
    caso <= 14;
    chaves_in  <= "0100";
    wait for 6*clockPeriod;


    ---- Teste 15 (ajustar chaves para 1000 por 6 periodos de clock)    
    caso <= 15;
    chaves_in  <= "1000";
    wait for 6*clockPeriod;


    ---- Teste 16 (ajustar chaves para 0001 por 3 periodos de clock)    
    caso <= 16;
    chaves_in  <= "0001";
    wait for 3*clockPeriod;

    ---- Teste 17 (ajustar chaves para 0100 por 3 periodos de clock)    
    caso <= 17;
    chaves_in  <= "0100";
    wait for 3*clockPeriod;

    ---- Teste 18 (ajustar chaves para 0100 por 1 periodos de clock)    
    caso <= 18;
    chaves_in  <= "0100";
    wait for 1*clockPeriod;

    ---- Teste 19 (ajustar chaves para 0001, acionar iniciar por 1 periodo de clock)
    caso <= 19;
    chaves_in  <= "0001";    
    -- pulso em iniciar
    wait until falling_edge(clock_in);
    iniciar_in <= '1';
    wait for clockPeriod;
    iniciar_in <= '0';

    ---- Teste 20 (ajustar chaves para 0001 por 3 periodos de clock)    
    caso <= 20;
    chaves_in  <= "0001";
    wait for 3*clockPeriod;

    ---- Teste 21 (ajustar chaves para 0010 por 3 periodos de clock)    
    caso <= 21;
    chaves_in  <= "0010";
    wait for 3*clockPeriod;

    ---- Teste 22 (ajustar chaves para 0100 por 3 periodos de clock)    
    caso <= 22;
    chaves_in  <= "0100";
    wait for 3*clockPeriod;

    ---- Teste 23 (ajustar chaves para 1000 por 3 periodos de clock)    
    caso <= 23;
    chaves_in  <= "1000";
    wait for 3*clockPeriod;
    
    ---- Teste 24 (ajustar chaves para 0100 por 3 periodos de clock)    
    caso <= 24;
    chaves_in  <= "0100";
    wait for 3*clockPeriod;

    ---- Jogada errada
    ---- Teste 25 (ajustar chaves para 0000 por 3 periodos de clock)    
    caso <= 25;
    chaves_in  <= "0000";
    wait for 3*clockPeriod;

    ---- Teste 26 (ajustar chaves para 0000 por 1 periodos de clock)    
    caso <= 26;
    chaves_in  <= "0000";
    wait for 1*clockPeriod;
    
    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
