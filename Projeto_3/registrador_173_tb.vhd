--------------------------------------------------------------------
-- Arquivo   : registrador_173_tb.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
--------------------------------------------------------------------
-- Descricao : registrador de 4 bits
--
--             1) plano de testes com 6 testes (descricao abaixo)
--
--             2) periodo de clock de 20 ns  
--                
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     18/01/2022  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity registrador_173_tb is
end entity;

architecture tb of registrador_173_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component registrador_173
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0)
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais (somente) para fins de simulacao (GHDL ou ModelSim)
  signal clock_in : std_logic := '0';
  signal clear_in : std_logic := '0';
  signal en1_in   : std_logic := '0';
  signal en2_in   : std_logic := '0';
  signal d_in     : std_logic_vector (3 downto 0) := "0000";
  signal q_out    : std_logic_vector (3 downto 0) := "0000";

  -- Configuração de tempo
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;
  
  -- Array de casos de teste
  type caso_teste_type is record
      id        : natural; 
      clear     : std_logic;
      dado      : std_logic_vector (3 downto 0);
      enable1   : std_logic;
      enable2   : std_logic;   
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
          ( 0, '0', "0000", '1', '1'),  -- c.i.
          ( 1, '1', "0000", '0', '0'),  -- teste 1: clear
          ( 2, '0', "1111", '0', '0'),  -- teste 2: load
          ( 3, '0', "0101", '1', '0'),  -- teste 4: en1 desativado
          ( 4, '0', "1010", '0', '1'),  -- teste 5: en2 desativado
          ( 5, '0', "0011", '1', '1'),  -- teste 6: en1 e en2 desativados
          ( 6, '1', "0101", '0', '0'),  -- teste 3: clear ativado e en1 e en2 desativados
          ( 7, '0', "1100", '0', '0')   -- teste 7: load
      );

  signal caso: integer := 0;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

  -- Conecta DUT (Device Under Test)
  dut: registrador_173
       port map ( 
           clock  => clock_in,
           clear  => clear_in,
           en1    => en1_in,
           en2    => en2_in,
           D      => d_in,
           Q      => q_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- loop pelos casos de teste
    for i in casos_teste'range loop
        -- imprime caso de teste
        assert false report "Caso de teste " & integer'image(casos_teste(i).id) severity note;
        -- seleciona sinais de entradas a partir do array de casos de teste
        caso     <= casos_teste(i).id;
        clear_in <= casos_teste(i).clear;
        d_in     <= casos_teste(i).dado;
        en1_in   <= casos_teste(i).enable1;
        en2_in   <= casos_teste(i).enable2;
        -- aciona entrada de clocks
        wait until falling_edge(clock_in);
    end loop;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
