--------------------------------------------------------------------
-- Arquivo   : comparador_85_tb.vhd
-- Projeto   : Experiencia 02 - Um Fluxo de Dados Simples
--------------------------------------------------------------------
-- Descricao : testbench para o comparador
--
--             1) plano de testes apresentado na apostila
--
--             2) periodo de clock de 20 ns  
--                
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/01/2022  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_16x4_tb is
end entity;

architecture tb of ram_16x4_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component ram_16x4
      port (
          clk          : in  std_logic;
          endereco     : in  std_logic_vector(3 downto 0);
          dado_entrada : in  std_logic_vector(3 downto 0);
          we           : in  std_logic;
          ce           : in  std_logic;
          dado_saida   : out std_logic_vector(3 downto 0)
      );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais (somente) para fins de simulacao (GHDL ou ModelSim)
  signal clk_in      : std_logic := '0';
  signal endereco_in : std_logic_vector (3 downto 0) := "0000";
  signal dado_in     : std_logic_vector (3 downto 0) := "0000";
  signal we_in       : std_logic := '0';
  -- signal ce_in       : std_logic := '0';
  signal dado_out    : std_logic_vector (3 downto 0) := "0000";


  -- Configuração de tempo
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns; 

  -- Casos de teste
  signal caso      : natural := 0;
  signal intervalo : natural := 5;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;

  -- Conecta DUT (Device Under Test)
  dut: entity work.ram_16x4(ram_modelsim)
       port map ( 
           clk           => clk_in,
           endereco      => endereco_in,
           dado_entrada  => dado_in,
           we            => we_in,
           ce            => '0',           -- memoria sempre habilitada
           dado_saida    => dado_out
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    
    ---- Caso de teste #1 (leitura da memoria)
    assert false report "Caso de teste 1 - leitura da memoria" severity note;
    caso   <= 1;
    we_in  <= '1';  -- leitura
    for e in 0 to 15 loop
        endereco_in <= std_logic_vector(to_unsigned(e, endereco_in'length));
        wait for clockPeriod;
    end loop;
    -- espera por 5 periodos de clock entre casos de teste
    wait for intervalo*clockPeriod;


    ---- Caso de teste #2 (escrita do dado 1111 na posicao 10 da memoria)
    assert false report "Caso de teste 1 - leitura da memoria" severity note;
    caso   <= 2;
    we_in  <= '0';  -- escrita
    endereco_in <= "1010";
    dado_in     <= "1111";
    wait for clockPeriod;
    we_in  <= '1';  -- encerra escrita
    -- espera por 5 periodos de clock entre casos de teste
    wait for intervalo*clockPeriod;


    ---- Caso de teste #3 (escrita do dado 1111 na posicao 4 da memoria)
    assert false report "Caso de teste 1 - leitura da memoria" severity note;
    caso   <= 3;
    we_in  <= '0';  -- escrita
    endereco_in <= "0100";
    dado_in     <= "1111";
    wait for clockPeriod;
    we_in  <= '1';  -- encerra escrita
    -- espera por 5 periodos de clock entre casos de teste
    wait for intervalo*clockPeriod;

    
    ---- Caso de teste #4 (leitura da memoria)
    assert false report "Caso de teste 4 - leitura da memoria" severity note;
    caso   <= 4;
    we_in  <= '1';  -- leitura
    for e in 0 to 15 loop
        endereco_in <= std_logic_vector(to_unsigned(e, endereco_in'length));
        wait for clockPeriod;
    end loop;
    -- espera por 5 periodos de clock entre casos de teste
    wait for intervalo*clockPeriod;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
