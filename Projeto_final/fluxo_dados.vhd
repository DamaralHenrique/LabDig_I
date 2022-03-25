------------------------------------------------------------------
-- Arquivo   : fluxo_dados.vhd
-- Projeto   : Tapa no tatu
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
    port (
        clock     : in std_logic;
        -- Registrador 6 bits
        registraM : in std_logic;
        limpaM    : in std_logic;
        -- db_tatus     : out std_logic_vector(5 downto 0);
        registraR : in std_logic;
        limpaR    : in std_logic;
        jogada    : in std_logic_vector(5 downto 0);
        -- Comparador 6 bits
        jogadaValida : out std_logic;
        -- Subtrator 6 bits
        temToupeira : out std_logic;
        -- Contador decrescente
        zeraJogTMR    : in  std_logic;
        contaJogTMR   : in  std_logic;
        limiteTMR     : in  integer;
        timeOutDeTMR  : out std_logic;
        db_contagem   : out integer;
        -- Contador de vidas
        zeraVida   : in std_logic;
        contaVida  : in std_logic;
        vidas      : out std_logic_vector(1 downto 0);
        fimVidas   : out std_logic;
        -- Pontuacao
        zeraPonto  : in std_logic;
        contaPonto : in std_logic;
        pontos     : out std_logic;
        -- LFSR6
        zeraLFSR6  : in std_logic
    );
 end entity fluxo_dados;
 
architecture estrutural of fluxo_dados is
  ----------------------------------
  -- Declaracao dos sinais usados --
  ----------------------------------
  s_tatus : std_logic_vector(5 downto 0);

  s_not_registraM : std_logic;

  ---------------------------------------
  -- Declaracao dos componentes usados --
  ---------------------------------------
  -- Comparador de 6 bits
  component	comparador_6_bits is
    port (
        i_A5    : in  std_logic;
        i_B5    : in  std_logic;
        i_A4    : in  std_logic;
        i_B4    : in  std_logic;
        i_A3    : in  std_logic;
        i_B3    : in  std_logic;
        i_A2    : in  std_logic;
        i_B2    : in  std_logic;
        i_A1    : in  std_logic;
        i_B1    : in  std_logic;
        i_A0    : in  std_logic;
        i_B0    : in  std_logic;
        o_ASEQB : out std_logic -- A "semiequal" B, indicando que Ai == Bi == 1, para algum i
      );
  end component;

  -- Subtrator 6 bits
  component subtrator_6_bits is
    i_A          : in  std_logic_vector(5 downto 0);
    i_B          : in  std_logic_vector(5 downto 0);
    resultado    : out std_logic_vector(5 downto 0); -- Resultado da subtracao
    tem_toupeira : out std_logic -- Booleana que indica se restou alguma toupeira
  end component;

  -- Registrador 6 bits
  component registrador_6_bits is
    port (
        clock : in  std_logic;
        clear : in  std_logic; -- Ativo ALTO
        en1   : in  std_logic; -- Ativo BAIXO
        en2   : in  std_logic;
        D     : in  std_logic_vector (5 downto 0);
        Q     : out std_logic_vector (5 downto 0)
    );
  end component;

  -- Contador decrescente
  component contador_decrescente is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic; -- Ativo ALTO
        conta       : in  std_logic;
        limite      : in  integer;
        timeout     : out std_logic;
        db_contagem : out integer
    );
  end component;

  -- Contador de vidas
  component contador_vidas is
    generic (
        constant nVidas: integer := 3 -- modulo do contador
    );
	
	port (
        clock    : in  std_logic;
        clr      : in  std_logic; -- Ativo BAIXO
        enp      : in  std_logic;
		acertou  : in  std_logic;
        vidasBin : out std_logic_vector (natural(ceil(log2(real(nVidas)))) - 1 downto 0);
        fimVidas : out std_logic
   );
  end component;

  -- Pontuacao
  component pontuacao is
    generic (
        constant limMax: integer := 100 -- modulo do contador (100 como valor provisorio)
    );
	port (
        clock   : in  std_logic;
        clr     : in  std_logic; -- Ativo BAIXO
        enp     : in  std_logic;
	    acertou : in  std_logic;
        pontos  : out std_logic_vector (natural(ceil(log2(real(limMax)))) - 1 downto 0) -- pokde ser menor que
   );
  end component;

  -- Gerador de jogadas aleatorias
  component LFSR6 is
    port (
        clk   : in  std_logic; 
        rst   : in  std_logic; -- Ativo ALTO
        output: out std_logic_vector (5 downto 0)
    );
  end component;

  -- Edge detector
  component edge_detector is
    port (
        clock  : in  std_logic;
        reset  : in  std_logic; -- Ativo ALTO
        sinal  : in  std_logic;
        pulso  : out std_logic
    );
  end component;

begin
  -- Sinais ativos baixo
  s_not_registraM <= not registraM;
  
  ---------------------------------------
  -- Instancias dos componentes usados --
  ---------------------------------------
  geradorJogadas: LFSR6
  port map (
    clk => clock,
    rst => zeraLFSR6,
    output => s_tatus
  );

  registraTatus: registrador_6_bits
  port (
    clock => clock,
    clear => limpaM,
    en1   => s_not_registraM,
    en2   => '0',
    D     => s_tatus, 
    Q     => 
  );
end estrutural;
