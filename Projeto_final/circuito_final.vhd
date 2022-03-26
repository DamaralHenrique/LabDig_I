------------------------------------------------------------------
-- Arquivo   : circuito_exp5.vhd
-- Projeto   : Experiencia 5
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     11/02/2022  1.0     Henrique Matheus  versao inicial
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity circuito_tapa_no_tatu is
    port (
    clock       : in std_logic;
    reset       : in std_logic;
    iniciar     : in std_logic;
    botoes      : in std_logic_vector(5 downto 0);
    dificuldade : in std_logic_vector(1 downto 0);
    leds        : out std_logic_vector(5 downto 0);
    fimDeJogo   : out std_logic;
    pontuacao   : out std_logic_vector (6 downto 0);
    vidas       : out std_logic_vector (1 downto 0);
    display1    : out std_logic_vector (6 downto 0);
    display2    : out std_logic_vector (6 downto 0);
    -- Sinais de depuração
    db_estado       : out std_logic_vector (6 downto 0);
    db_jogadaFeita  : out std_logic;
    db_jogadaValida : out std_logic;
    db_timeout      : out std_logic;
    db_JogadaErrada : out std_logic
    );
end entity;

architecture estrutural of circuito_tapa_no_tatu is
    signal s_registraM, s_limpaM, s_registraR, s_limpaR: std_logic;
    signal s_jogada_valida, s_tem_tatu: std_logic;
    signal s_conta_jog_TMR, s_timeout_TMR, s_zeraJogTMR: std_logic;
    signal s_limite_TMR, s_contagem: integer;
    signal s_conta_Del_TMR, s_timeout_Del_TMR, s_zeraDelTMR: std_logic;
    signal s_fim_vidas: std_logic;
    signal s_vidas: std_logic_vector(1 downto 0);
    signal s_conta_ponto: std_logic;
    signal s_pontos: std_logic_vector(natural(ceil(log2(real(100)))) - 1 downto 0);
    signal s_estado: out std_logic_vector(4 downto 0);
    signal s_fimJogo: std_logic;
    -- Fluxo de dados
    -- Adicionar edge detector
    component fluxo_dados is
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
      end component fluxo_dados;
    -- Unidade de controle
    component unidade_controle is 
    port ( 
        clock                  : in  std_logic; 
        reset                  : in  std_logic; 
        iniciar                : in  std_logic;
        EscolheuDificuldade    : in  std_logic;
        timeout                : in  std_logic;
        fezJogada              : in  std_logic;
        temVida                : in  std_logic;
        jogadaValida           : in  std_logic;
        temToupeira            : in  std_logic;
        timeOutDelTMR          : in  std_logic;
        fimJogo                : out std_logic; 
        zeraR                  : out std_logic; 
        registraR              : out std_logic; 
        limpaR                 : out std_logic; 
        registraM              : out std_logic; 
        limpaM                 : out std_logic; 
        zeraJogTMR             : out std_logic; 
        contaJogTMR            : out std_logic;
        zeraDelTMR             : out std_logic; 
        db_estado              : out std_logic_vector(4 downto 0)
    );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos
    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos para os estados
    component estado7seg is
        port (
            estado : in  std_logic_vector(4 downto 0);
            sseg   : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    fd: fluxo_dados
    port map (
        clock         => clock,
        -- Registrador 6 bits
        registraM     => s_registraM,
        limpaM        => s_limpaM,
        registraR     => s_registraR,
        limpaR        => s_limpaR,
        jogada        => botoes,
        -- Comparador 6 bits
        jogada_valida => s_jogada_valida,
        -- Subtrator 6 bits
        tem_tatu      => s_tem_tatu,
        -- Contador decrescente
        conta_jog_TMR => s_conta_jog_TMR, -- Falta zerar!
        limite_TMR    => s_limite_TMR,
        timeout_TMR   => s_timeout_TMR,
        db_contagem   => s_db_contagem,
        -- Contador de vidas
        zera_vida     => reset,
        vidas         => s_vidas,
        fim_vidas     => s_fim_vidas,
        -- Pontuacao
        zera_ponto    => reset,
        conta_ponto   => s_conta_ponto,
        pontos        => s_pontos,
        -- LFSR6
        zera_LFSR6    => reset
    );

    uc: unidade_controle
    port map (
        clock                => clock,
        reset                => reset, 
        iniciar              => iniciar,
        EscolheuDificuldade  => , -- Mudar pra receber dificuldade, a UC que seta o valor do tempo inicial
        timeout              => s_timeout_TMR,
        fezJogada            => ,
        temVida              => not s_fim_vidas,
        jogadaValida         => s_jogada_valida,
        temToupeira          => s_tem_tatu, --TATU
        timeOutDelTMR        => s_timeout_Del_TMR,
        fimJogo              => s_fimJogo,
        zeraR                => s_limpaR, 
        registraR            => s_registraR,
        limpaR               => s_limpaR,
        registraM            => s_registraM,
        limpaM               => s_limpaM,
        zeraJogTMR           => s_zeraJogTMR,
        contaJogTMR          => s_conta_jog_TMR,
        zeraDelTMR           => s_zeraDelTMR, -- Falta um conta pra o tempo sem jogada
        db_estado            => s_estado
    );

end architecture;
   
