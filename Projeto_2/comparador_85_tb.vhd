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

entity comparador_85_tb is
end entity;

architecture tb of comparador_85_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component comparador_85 is
    port (
      i_A3   : in  std_logic;
      i_B3   : in  std_logic;
      i_A2   : in  std_logic;
      i_B2   : in  std_logic;
      i_A1   : in  std_logic;
      i_B1   : in  std_logic;
      i_A0   : in  std_logic;
      i_B0   : in  std_logic;
      i_AGTB : in  std_logic;
      i_ALTB : in  std_logic;
      i_AEQB : in  std_logic;
      o_AGTB : out std_logic;
      o_ALTB : out std_logic;
      o_AEQB : out std_logic
      );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais (somente) para fins de simulacao (GHDL ou ModelSim)
  signal agtb_in  : std_logic := '0';
  signal aeqb_in  : std_logic := '0';
  signal altb_in  : std_logic := '0';
  signal a_in     : std_logic_vector (3 downto 0) := "0000";
  signal b_in     : std_logic_vector (3 downto 0) := "0000";
  signal agtb_out : std_logic := '0';
  signal aeqb_out : std_logic := '0';
  signal altb_out : std_logic := '0';

  -- Configuração de tempo
  constant clockPeriod   : time := 20 ns;
  
  -- Array de casos de teste
  signal id : natural;
  type caso_teste_type is record
      id        : natural; 
      AmaiorB   : std_logic;
      AigualB   : std_logic;
      AmenorB   : std_logic;
      dadoA     : std_logic_vector (3 downto 0); 
      dadoB     : std_logic_vector (3 downto 0); 
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        ( 0, '0', '1', '0', "0000", "0000"),  -- condicoes iniciais
        ( 1, '0', '1', '0', "0110", "0110"),  -- teste 1
        ( 2, '1', '0', '0', "0110", "0110"),  -- teste 2
        ( 3, '0', '0', '1', "0110", "0110"),  -- teste 3
        ( 4, '0', '1', '0', "0001", "0000"),  -- teste 4
        ( 5, '1', '0', '0', "0001", "0000"),  -- teste 5
        ( 6, '0', '0', '1', "0001", "0000"),  -- teste 6
        ( 7, '0', '1', '0', "0011", "1100"),  -- teste 7
        ( 8, '1', '0', '0', "0011", "1100"),  -- teste 8
        ( 9, '0', '1', '0', "0011", "1100")   -- teste 9
      );

begin

  -- Conecta DUT (Device Under Test)
  dut: comparador_85
       port map ( 
           i_A3   => a_in(3),
           i_B3   => b_in(3),
           i_A2   => a_in(2),
           i_B2   => b_in(2),
           i_A1   => a_in(1),
           i_B1   => b_in(1),
           i_A0   => a_in(0),
           i_B0   => b_in(0),
           i_AGTB => agtb_in,
           i_ALTB => altb_in,
           i_AEQB => aeqb_in,
           o_AGTB => agtb_out,
           o_ALTB => altb_out,
           o_AEQB => aeqb_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    
    ---- loop pelos casos de teste
    for i in casos_teste'range loop

        -- imprime caso de teste
        assert false report "Caso de teste " & integer'image(casos_teste(i).id) severity note;

        -- seleciona sinais de entradas a partir do array de casos de teste
        id      <= casos_teste(i).id;
        agtb_in <= casos_teste(i).AmaiorB;
        aeqb_in <= casos_teste(i).AigualB;
        altb_in <= casos_teste(i).AmenorB;
        a_in    <= casos_teste(i).dadoA;
        b_in    <= casos_teste(i).dadoB;

        -- espera por 1 periodo de clock
        wait for clockPeriod;

    end loop;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
