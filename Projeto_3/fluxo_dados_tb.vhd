--------------------------------------------------------------------
-- Arquivo   : fluxo_dados_tb.vhd
-- Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle
--------------------------------------------------------------------
-- Descricao : testbench para fluxo de dados 
--
--             1) plano de teste: 9 casos de teste
--
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     18/01/2022  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity fluxo_dados_tb is
end entity;

architecture tb of fluxo_dados_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component fluxo_dados is
      port (
          clock               : in  std_logic;
          zeraC               : in  std_logic;
          contaC              : in  std_logic;
          escreveM            : in  std_logic;
          zeraR               : in  std_logic;
          registraR           : in  std_logic;
          chaves              : in  std_logic_vector (3 downto 0);
          chavesIgualMemoria  : out std_logic;
          fimC                : out std_logic;
          db_contagem         : out std_logic_vector (3 downto 0);
          db_memoria          : out std_logic_vector (3 downto 0);
          db_chaves           : out std_logic_vector (3 downto 0)
      );
    end component;
    
    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
    signal clock_in         : std_logic := '0';
    signal zerac_in         : std_logic := '0';
    signal contac_in        : std_logic := '0';
    signal escrevem_in      : std_logic := '0';
    signal zerar_in         : std_logic := '0';
    signal registram_in     : std_logic := '0';  
    signal chaves_in        : std_logic_vector (3 downto 0) := "0000";
    signal igual_out        : std_logic := '0';
    signal fimc_out         : std_logic := '0';
    signal db_contagem_out  : std_logic_vector (3 downto 0) := "0000";
    signal db_memoria_out   : std_logic_vector (3 downto 0) := "0000";
    signal db_chaves_out    : std_logic_vector (3 downto 0) := "0000";
  
    -- Array de casos de teste
    type caso_teste_type is record
        id        : natural; 
        zerac     : std_logic;
        contac    : std_logic;
        zerar     : std_logic;
        registrar : std_logic;
        chaves    : std_logic_vector (3 downto 0);
        vezes     : integer;     
    end record;
    
    type casos_teste_array is array (natural range <>) of caso_teste_type;
    constant casos_teste : casos_teste_array :=
        (--  id   contador  registrador  chaves  vezes
            ( 0,  '0', '0',  '0', '0',   "0000",  1),  -- c.i.
            ( 1,  '1', '0',  '1', '0',   "0000",  1),  -- teste 1  - zera contador e registrador
            ( 2,  '0', '0',  '0', '0',   "0001",  1),  -- teste 2  - chaves=0001, endereco=0000, dado=0001, igual=0
            ( 3,  '0', '0',  '0', '1',   "0001",  1),  -- teste 3  - chaves=0001, registra chaves => db_chaves=0001
            ( 4,  '0', '0',  '0', '0',   "0001",  1),  -- teste 4  - chaves=0001, endereco=0000, dado=0001, igual=1
            ( 5,  '0', '1',  '0', '0',   "0001",  1),  -- teste 5  - incrementa contador, endereco=0001
            ( 6,  '0', '0',  '0', '1',   "0010",  1),  -- teste 6  - chaves=0010, registra chaves => db_chaves=0010
            ( 7,  '0', '0',  '0', '0',   "0010",  1),  -- teste 7  - chaves=0010, endereco=0001, dado=0010, igual=1
            ( 8,  '0', '1',  '0', '0',   "0010",  1),  -- teste 8  - incrementa contador, endereco=0010
            ( 9,  '0', '0',  '0', '1',   "1000",  1),  -- teste 9  - chaves=1000, registra chaves => db_chaves=1000
            (10,  '0', '0',  '0', '0',   "1000",  1),  -- teste 10 - chaves=1000, endereco=0010, dado=0100, igual=0
            (11,  '0', '1',  '0', '0',   "1000", 13)   -- teste 11 - incrementa contador até 15 (incrementa 13x) => fimC=1
        );

    -- Identificacao de casos de teste
    signal caso  : integer := 0;
    signal vezes : integer := 0;
  
    -- Configurações do clock
    signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod: time := 20 ns;


begin
 
    -- Conecta DUT (Device Under Test)
    dut: fluxo_dados 
         port map( 
             clock               => clock_in,
             zeraC               => zerac_in,
             contaC              => contac_in,
             escreveM            => escrevem_in,
             zeraR               => zerar_in,
             registraR           => registram_in,
             chaves              => chaves_in,
             chavesIgualMemoria  => igual_out,
             fimC                => fimc_out,
             db_contagem         => db_contagem_out,
             db_memoria          => db_memoria_out,
             db_chaves           => db_chaves_out
         );

    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
    -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
    clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

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
            caso       <= casos_teste(i).id;
            chaves_in  <= casos_teste(i).chaves;
            vezes      <= casos_teste(i).vezes;
            assert false report "vezes " & integer'image(casos_teste(i).vezes) severity note;
            -- repete por "vezes" vezes
            for j in 1 to casos_teste(i).vezes loop
                zerac_in     <= casos_teste(i).zerac;
                contac_in    <= casos_teste(i).contac;
                zerar_in     <= casos_teste(i).zerar;
                registram_in <= casos_teste(i).registrar;
                -- espera 1 periodo de clock
                wait for clockPeriod;
                -- restaura c.i. para sinais de controle
                zerac_in     <= casos_teste(0).zerac;
                contac_in    <= casos_teste(0).contac;
                zerar_in     <= casos_teste(0).zerar;
                registram_in <= casos_teste(0).registrar;
            end loop;
            -- espera borda de descida
            wait until falling_edge(clock_in);
        end loop;

        ---- final dos casos de teste  da simulacao
        keep_simulating <= '0';
        assert false report "Fim da simulacao" severity note;
        
        wait; -- fim da simulação: aguarda indefinidamente
    end process;

end architecture;
