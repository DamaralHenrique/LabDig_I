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
    clock         : in  std_logic;
    -- Registrador 6 bits
    registraM     : in  std_logic;
    limpaM        : in  std_logic;
    registraR     : in  std_logic;
    limpaR        : in  std_logic;
    jogada        : in  std_logic_vector(5 downto 0);
    -- Comparador 6 bits
    jogada_valida : out std_logic;
    -- Subtrator 6 bits
    tem_tatu      : out std_logic;
    -- Contador decrescente
    conta_jog_TMR : in  std_logic;
    limite_TMR    : in  integer;
    timeout_TMR   : out std_logic;
    db_contagem   : out integer;
    -- Contador de vidas
    zera_vida     : in  std_logic;
    vidas         : out std_logic_vector(1 downto 0);
    fim_vidas     : out std_logic;
    -- Pontuacao
    zera_ponto    : in  std_logic;
    conta_ponto   : in  std_logic;
    pontos        : out std_logic_vector (natural(ceil(log2(real(100)))) - 1 downto 0);
    -- LFSR6
    zera_LFSR6    : in  std_logic
  );
end entity fluxo_dados;
 
architecture estrutural of fluxo_dados is
  ----------------------------------
  -- Declaracao dos sinais usados --
  ----------------------------------
  signal s_jogada  : std_logic_vector(5 downto 0);
  signal s_tatusR  : std_logic_vector(5 downto 0);
  signal s_jogadaR : std_logic_vector(5 downto 0);

  signal s_not_registraM  : std_logic;
  signal s_not_registraR  : std_logic;
  signal s_not_zera_vida  : std_logic;
  signal s_not_zera_ponto : std_logic;

  signal s_jogada_valida : std_logic;
  signal s_tem_tatu      : std_logic;
  signal s_not_tem_tatu  : std_logic;

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
    port (
      i_A          : in  std_logic_vector(5 downto 0);
      i_B          : in  std_logic_vector(5 downto 0);
      resultado    : out std_logic_vector(5 downto 0);
      tem_toupeira : out std_logic
    );
  end component;

  -- Registrador 6 bits
  component registrador_173 is
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
      conta       : in  std_logic; -- Ativo ALTO
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
      pontos  : out std_logic_vector (natural(ceil(log2(real(limMax)))) - 1 downto 0) -- pode ser menor que
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

begin
  -- Sinais ativos baixo
  s_not_registraM  <= not registraM;
  s_not_registraR  <= not registraR;
  s_not_zera_vida  <= not zera_vida;
  s_not_zera_ponto <= not zera_ponto;

  ---------------------------------------
  -- Instancias dos componentes usados --
  ---------------------------------------
  geradorJogadas: LFSR6
  port map (
    clk    => clock,
    rst    => zera_LFSR6,
    output => s_jogada
  );

  registraTatus: registrador_173
  port map (
    clock => clock,
    clear => limpaM,
    en1   => s_not_registraM,
    en2   => '0',
    D     => s_jogada, 
    Q     => s_tatusR
  );

  registraJogada: registrador_173
  port map (
    clock => clock,
    clear => limpaR,
    en1   => s_not_registraR,
    en2   => '0',
    D     => jogada, 
    Q     => s_jogadaR
  );

  comparaTatusJogada: comparador_6_bits
  port map (
    i_A5    => s_tatusR(5),
    i_B5    => s_jogadaR(5),
    i_A4    => s_tatusR(4),
    i_B4    => s_jogadaR(4),
    i_A3    => s_tatusR(3),
    i_B3    => s_jogadaR(3),
    i_A2    => s_tatusR(2),
    i_B2    => s_jogadaR(2),
    i_A1    => s_tatusR(1),
    i_B1    => s_jogadaR(1),
    i_A0    => s_tatusR(0),
    i_B0    => s_jogadaR(0),
    o_ASEQB => s_jogada_valida
  );

  conta_vidas: contador_vidas
  port map (
    clock    => clock,
    clr      => s_not_zera_vida,
    enp      => '1',
    acertou  => s_jogada_valida,
    vidasBin => vidas,
    fimVidas => fim_vidas
  );

  conta_pontos: pontuacao
  port map (
    clock   => clock,
    clr     => s_not_zera_ponto,
    enp     => '1',
    acertou => s_jogada_valida,
    pontos  => pontos
  );

  remove_tatu: subtrator_6_bits
  port map (
    i_A          => s_tatusR,
    i_B          => s_jogadaR,
    resultado    => s_jogada,
    tem_toupeira => s_tem_tatu
  );

  reduzTempo: contador_decrescente
  port map (
    clock       => clock,
    reset       => s_not_tem_tatu,
    conta       => conta_jog_TMR,
    limite      => limite_TMR,
    timeout     => timeout_TMR,
    db_contagem => db_contagem
  );

  s_not_tem_tatu <= not s_tem_tatu;

  -- Sinais de saida
  jogada_valida <= s_jogada_valida;
  tem_tatu <= s_tem_tatu;
end estrutural;
