--------------------------------------------------------------------
-- Arquivo   : circuito_exp2_desafio_tb.vhd
-- Projeto   : Experiencia 2 - Desafio
--------------------------------------------------------------------
-- Descricao : testbench para circuito do desafio 
--
--             1) plano de teste: 11 casos de teste
--
-- 
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp2_desafio_tb is
end entity;

architecture tb of circuito_exp2_desafio_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component circuito_exp2_desafio is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        enable      : in  std_logic;
        escreve     : in  std_logic;
        chaves      : in  std_logic_vector (3 downto 0);
        igual       : out std_logic;
        fim         : out std_logic;
        db_contagem : out std_logic_vector (6 downto 0);
        db_memoria  : out std_logic_vector (6 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in         : std_logic := '0';
  signal reset_in         : std_logic := '0';
  signal enable_in        : std_logic := '0';
  signal escreve_in       : std_logic := '0';
  signal chaves_in        : std_logic_vector (3 downto 0) := "0000";
  signal igual_out        : std_logic := '0';
  signal fim_out          : std_logic := '0';
  signal db_contagem_out  : std_logic_vector (6 downto 0) := "0000000";
  signal db_memoria_out   : std_logic_vector (6 downto 0) := "0000000";

  -- Configurações do clock
  constant clockPeriod: time := 20 ns;
  
  -- Identificacao de casos de teste
  signal caso : integer := 0;

begin
 
  -- Conecta DUT (Device Under Test)
  dut: circuito_exp2_desafio 
       port map( 
           clock        => clock_in,
           reset        => reset_in,
           enable       => enable_in,
           escreve      => escreve_in,
           chaves       => chaves_in,
           igual        => igual_out,
           fim          => fim_out,
           db_contagem  => db_contagem_out,
           db_memoria   => db_memoria_out 
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    
    ---- condicoes iniciais ----------------
    caso       <= 0;
    clock_in   <= '0';
    reset_in   <= '0';
    enable_in  <= '0';
    escreve_in <= '0';
    chaves_in  <= "0000";
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 1 (zerar contador e observar a saída)    
    caso <= 1;
    reset_in   <= '1';
    -- 1 borda de clock
    clock_in   <= '0';
    wait for clockPeriod/2;
    clock_in   <= '1';
    wait for clockPeriod/2;
    clock_in   <= '0';
    reset_in   <= '0';
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 2 (ajustar chaves para 0001 e observar a saída)    
    caso <= 2;
    chaves_in  <= "0001";
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;

    ---- Teste 3 (ajustar chaves para 1111 e observar a saída)    
    caso <= 3;
    chaves_in  <= "1111";
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 4 (incrementar endereco para 2, ajustar chaves para 0100 e observar a saída)    
    caso <= 4;
    chaves_in  <= "0100";
    enable_in  <= '1';
    wait for clockPeriod;
    clock_in   <= '0';
    -- 2 bordas de clock
    for cont in 1 to 2 loop
        clock_in   <= '1';
        wait for clockPeriod/2;
        clock_in   <= '0';
        wait for clockPeriod/2;
    end loop;
    enable_in  <= '0';
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 5 (ajustar chaves para 1010, acionar escreve e observar a saída)    
    caso <= 5;
    chaves_in   <= "1010";
    escreve_in  <= '1';
    -- borda de clock
    clock_in    <= '0';
    wait for clockPeriod/2;
    clock_in    <= '1';
    wait for clockPeriod/2;
    clock_in    <= '0';
    escreve_in  <= '0';
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 6 (zera contador, ajustar chaves para 1111 e observar a saída)    
    caso <= 6;
    chaves_in  <= "1111";
    reset_in   <= '1';
    -- 1 borda de clock
    clock_in   <= '0';
    wait for clockPeriod/2;
    clock_in   <= '1';
    wait for clockPeriod/2;
    clock_in   <= '0';
    reset_in   <= '0';
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 7 (incrementar endereco para 2 e observar a saída)    
    caso <= 7;
    enable_in  <= '1';
    wait for clockPeriod;
    clock_in   <= '0';
    -- 2 bordas de clock
    for cont in 1 to 2 loop
        clock_in   <= '1';
        wait for clockPeriod/2;
        clock_in   <= '0';
        wait for clockPeriod/2;
    end loop;
    enable_in  <= '0';
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 8 (incrementar endereco até F e observar a saída)    
    caso <= 8;
    enable_in  <= '1';
    wait for clockPeriod;
    clock_in   <= '0';
    -- 2 bordas de clock
    for cont in 1 to 13 loop
        clock_in   <= '1';
        wait for clockPeriod/2;
        clock_in   <= '0';
        wait for clockPeriod/2;
    end loop;
    enable_in  <= '0';
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;


    ---- Teste 9 (ajustar chaves para 0100 e observar a saída)    
    caso <= 9;
    chaves_in  <= "0100";
    -- espera por 5 periodos de clock entre testes
    wait for 5*clockPeriod;

    ---- Teste 10 (Escrever 1111 e incrementar simultaneamente)    
    caso <= 10;
    chaves_in  <= "1111";
    escreve_in <= '1';
    enable_in  <= '1';
    -- espera por 1 periodo de clock entre testes
    wait for 1*clockPeriod;

    ---- Teste 11 (incrementar endereço até F)    
    caso <= 11;
    escreve_in <= '0';
    -- espera por 15 periodos de clock entre testes
    wait for 15*clockPeriod;


    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
