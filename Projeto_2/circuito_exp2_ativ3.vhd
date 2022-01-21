------------------------------------------------------------------
-- Arquivo   : circuito_exp2_atv3.vhd
-- Projeto   : Experiencia 02 - Um Fluxo de Dados Simples
------------------------------------------------------------------
-- Descricao : Descricao estrutural do circuito logico da
--             experiencia 02
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp2_ativ3 is
   port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        enable      : in  std_logic;
        escreve     : in  std_logic;
        chaves      : in  std_logic_vector (3 downto 0);
        igual       : out std_logic;
        fim         : out std_logic;
        db_contagem : out std_logic_vector (3 downto 0);
        db_memoria  : out std_logic_vector (3 downto 0)
   );
end entity;

architecture estrutural of circuito_exp2_ativ3 is

  signal s_endereco    : std_logic_vector (3 downto 0); -- Endereco de saida
  signal s_dado        : std_logic_vector (3 downto 0); -- Dado de saida

  signal s_not_reset   : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo do reset
  signal s_not_escreve : std_logic; -- Sinal auxiliar devido ao comportamento ativo baixo da escrita

  -- Contador binario modulo 16
  component contador_163
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
    );
  end component;

  -- Comparador de 4 bits, com operacoes de maior, menor e igual
  component comparador_85
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

  -- Memoria RAM 16x4
  component ram_16x4 is
    port (       
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(3 downto 0);
       dado_entrada : in  std_logic_vector(3 downto 0);
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(3 downto 0)
    );
  end component;

begin

  s_not_reset   <= not reset;
  s_not_escreve <= not escreve;
  
  contador: contador_163
    port map (
        clock => clock,
        clr   => s_not_reset, -- clr ativo baixo
        ld => '1', -- ld inativo
        ent => '1',
        enp => enable,
        D => "0000",
        Q => s_endereco,
        rco => fim
    );


  comparador: comparador_85
    port map (
        i_A3   => s_dado(3),
        i_B3   => chaves(3),
        i_A2   => s_dado(2),
        i_B2   => chaves(2),
        i_A1   => s_dado(1),
        i_B1   => chaves(1),
        i_A0   => s_dado(0),
        i_B0   => chaves(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1', -- Executa a operacao de igualdade entre "A" e "B"
        o_AGTB => open,
        o_ALTB => open,
        o_AEQB => igual -- Saida que indica se "A = B"
    );


  memoria: ram_16x4  -- usar para Quartus
--   memoria: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => chaves,
       we           => s_not_escreve, -- we ativo baixo
       ce           => '0',
       dado_saida   => s_dado
    );

  db_contagem <= s_endereco; -- Para debbug: valor da contagem (valor do endereco da memoria)
  db_memoria  <= s_dado;     -- Para debbug: valor da memoria (valor do dado acessado)

end estrutural;
