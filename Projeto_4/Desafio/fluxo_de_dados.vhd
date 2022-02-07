------------------------------------------------------------------
-- Arquivo   : circuito_exp2_atv3.vhd
-- Projeto   : Experiencia 02 - Um Fluxo de Dados Simples
------------------------------------------------------------------
-- Descricao : Descricao estrutural do circuito logico da
--             experiencia 02
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
    port (
        clock : in std_logic;
        zeraC : in std_logic;
        contaC : in std_logic;
        escreveM : in std_logic;
        zeraR : in std_logic;
        registraR : in std_logic;
        chaves : in std_logic_vector (3 downto 0);
        igual : out std_logic;
        fimC : out std_logic;      
        jogada_feita : out std_logic;
        db_tem_jogada : out std_logic;
        db_contagem : out std_logic_vector (3 downto 0);
        db_memoria : out std_logic_vector (3 downto 0);
        db_jogada : out std_logic_vector (3 downto 0);
        --Novos sinais
        zeraM : in std_logic;
        contaM : in std_logic;
        fimM : out std_logic
    );
 end entity fluxo_dados;
 
architecture estrutural of fluxo_dados is

  signal s_endereco    : std_logic_vector (3 downto 0);
  signal s_dado        : std_logic_vector (3 downto 0);
  signal s_chaves      : std_logic_vector (3 downto 0);
  signal valor_contado : std_logic_vector(natural(ceil(log2(real(5000))))-1 downto 0); -- Contador de tempo para a jogada do jogador

  signal s_not_zeraC     : std_logic;
  signal s_not_escreveM  : std_logic;
  signal s_not_registraR : std_logic;
  signal s_chaveacionada : std_logic;

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
  
  -- Contador de tamanho variado
  component contador_m is
    generic (
        constant M: integer := 5000 -- modulo do contador
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic
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

  -- registrador de 4 bits
  component registrador_173 is
    port (
        clock : in  std_logic;
        clear : in  std_logic;
        en1   : in  std_logic;
        en2   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0)
   );
end component registrador_173;

component edge_detector is
  port (
      clock  : in  std_logic;
      reset  : in  std_logic;
      sinal  : in  std_logic;
      pulso  : out std_logic
  );
end component edge_detector;

begin

  -- Sinais ativos baixo
  s_not_zeraC     <= not zeraC;
  s_not_escreveM  <= not escreveM;
  s_not_registraR <= not registraR;

  s_chaveacionada <= chaves(0) or chaves(1) or chaves(2) or chaves(3);
  
  contador: contador_163
    port map (
        clock => clock,
        clr   => s_not_zeraC,
        ld    => '1',
        ent   => '1',
        enp   => contaC,
        D     => "0000",
        Q     => s_endereco,
        rco   => fimC
    );
	 
  -- Declaração dos sinais do novo contador
  contadorM: contador_m
    port map (
        clock   => clock,
        zera_as => zeraM,
		zera_s  => zeraM,
        conta   => contaM,
        Q       => valor_contado,
        fim     => fimM,
		meio    => open -- Sinal não utilizado na lógica atual
    );
	 
  comparador: comparador_85
    port map (
        i_A3   => s_dado(3),
        i_B3   => s_chaves(3),
        i_A2   => s_dado(2),
        i_B2   => s_chaves(2),
        i_A1   => s_dado(1),
        i_B1   => s_chaves(1),
        i_A0   => s_dado(0),
        i_B0   => s_chaves(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => open,
        o_ALTB => open,
        o_AEQB => igual
    );


  -- memoria: ram_16x4  -- usar para Quartus
  memoria: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
    port map (
       clk          => clock,
       endereco     => s_endereco,
       dado_entrada => s_chaves,
       we           => s_not_escreveM, -- we ativo baixo
       ce           => '0',
       dado_saida   => s_dado
    );

  registrador: registrador_173 
    port map (
       clock => clock,
       clear => zeraR,
       en1   => s_not_registraR,
       en2   => '0',
       D     => chaves,
       Q     => s_chaves
    );

  edgeDetector: edge_detector 
    port map (
       clock => clock,
       reset => zeraR,
       sinal => s_chaveacionada,
       pulso => jogada_feita
    );

  db_contagem   <= s_endereco;      
  db_memoria    <= s_dado;          
  db_tem_jogada <= s_chaveacionada; 
  db_jogada     <= s_chaves;        

end estrutural;

