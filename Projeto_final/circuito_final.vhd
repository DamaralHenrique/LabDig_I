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
use ieee.numeric_std.all;
use ieee.math_real.all;

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
    db_timeout      : out std_logic
    );
end entity;

architecture estrutural of circuito_tapa_no_tatu is
    signal s_registraM, s_limpaM, s_registraR, s_limpaR: std_logic;
    signal s_jogada_valida, s_tem_tatu, s_en_FLSR: std_logic;
    signal s_conta_jog_TMR, s_timeout_TMR, s_zeraJogTMR: std_logic;
    signal s_limite_TMR, s_contagem: integer;
    signal s_contaDelTMR, s_timeout_Del_TMR, s_zeraDelTMR: std_logic;
    signal s_fim_vidas, s_not_fim_vidas: std_logic;
    signal s_conta_vida : std_logic;
    signal s_vidas: std_logic_vector(1 downto 0);
    signal s_conta_ponto: std_logic;
    signal s_pontos: std_logic_vector(natural(ceil(log2(real(100)))) - 1 downto 0);
    signal s_estado: std_logic_vector(4 downto 0);
    signal s_fimJogo, s_tem_jogada, s_escolheuDificuldade: std_logic;
    signal s_loadSub, s_contaSub: std_logic;
    signal s_hexa1, s_hexa2: std_logic_vector(3 downto 0);
    signal s_emJogo: std_logic;
    signal s_tatus : std_logic_vector(5 downto 0);

    -- Fluxo de dados
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
			 tatus         : out std_logic_vector(5 downto 0);
          -- Contador decrescente
          conta_jog_TMR : in  std_logic;
          timeout_TMR   : out std_logic;
          db_contagem   : out integer;
          -- Contador de vidas
          zera_vida     : in  std_logic;
          conta_vida    : in  std_logic;
          vidas         : out std_logic_vector(1 downto 0);
          fim_vidas     : out std_logic;
          -- Pontuacao
          zera_ponto    : in  std_logic;
          conta_ponto   : in  std_logic;
          pontos        : out std_logic_vector (natural(ceil(log2(real(100)))) - 1 downto 0);
          -- LFSR6
          zera_LFSR6    : in  std_logic;
          en_LFSR       : in  std_logic;
          -- Edge detector
          tem_jogada          : out std_logic;
          escolheuDificuldade : out std_logic;
          dificuldade         : in std_logic_vector(1 downto 0);
          -- TMR apagado
          contaDelTMR : in std_logic;
          zeraDelTMR  : in std_logic;
          fimDelTMR   : out std_logic;
          -- Subtrator
          loadSub  : in std_logic;
          contaSub : in std_logic
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
        temTatu                : in  std_logic;
        timeOutDelTMR          : in  std_logic;
        fimJogo                : out std_logic; 
        registraR              : out std_logic; 
        limpaR                 : out std_logic; 
        registraM              : out std_logic; 
        limpaM                 : out std_logic; 
        zeraJogTMR             : out std_logic; 
        contaJogTMR            : out std_logic;
        zeraDelTMR             : out std_logic;
        contaDelTMR            : out std_logic;
        loadSub                : out std_logic;
        contaSub               : out std_logic;
        en_FLSR                : out std_logic; 
        emJogo                 : out std_logic;
        contaPonto             : out std_logic;
        contaVida              : out std_logic;
        db_estado              : out std_logic_vector(4 downto 0)
    );
    end component;

    -- Decodificador hexadecimal para display de 7 segmentos
    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            enable : in std_logic;
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
        tatus         => s_tatus,
        -- Contador decrescente
        conta_jog_TMR => s_conta_jog_TMR, -- Falta zerar!
        timeout_TMR   => s_timeout_TMR,
        db_contagem   => s_contagem,
        -- Contador de vidas
        zera_vida     => reset,
        conta_vida    => s_conta_vida,
        vidas         => s_vidas,
        fim_vidas     => s_fim_vidas,
        -- Pontuacao
        zera_ponto    => reset,
        conta_ponto   => s_conta_ponto,
        pontos        => s_pontos,
        -- LFSR6
        zera_LFSR6    => reset,
        en_LFSR       => s_en_FLSR,
        -- Edge detector
        tem_jogada          => s_tem_jogada,
        escolheuDificuldade => s_escolheuDificuldade,
        dificuldade         => dificuldade,
        -- TMR apagado
        contaDelTMR => s_contaDelTMR,
        zeraDelTMR  => s_zeraDelTMR,
        fimDelTMR   => s_timeout_Del_TMR,
        -- Subtrator
        loadSub  => s_loadSub,
        contaSub => s_contaSub
    );

    uc: unidade_controle
    port map (
        clock                => clock,
        reset                => reset, 
        iniciar              => iniciar,
        EscolheuDificuldade  => s_escolheuDificuldade,
        timeout              => s_timeout_TMR,
        fezJogada            => s_tem_jogada,
        temVida              => s_not_fim_vidas,
        jogadaValida         => s_jogada_valida,
        temTatu              => s_tem_tatu,
        timeOutDelTMR        => s_timeout_Del_TMR,
        fimJogo              => s_fimJogo,
        registraR            => s_registraR,
        limpaR               => s_limpaR,
        registraM            => s_registraM,
        limpaM               => s_limpaM,
        zeraJogTMR           => s_zeraJogTMR,
        contaJogTMR          => s_conta_jog_TMR,
        zeraDelTMR           => s_zeraDelTMR,
        contaDelTMR          => s_contaDelTMR,
        loadSub              => s_loadSub,
        contaSub             => s_contaSub,
        en_FLSR              => s_en_FLSR,
        emJogo               => s_emJogo,
        contaPonto           => s_conta_ponto,
        contaVida            => s_conta_vida,
        db_estado            => s_estado
    );
	 
	 process(s_vidas, s_emJogo, s_pontos) 
	 begin
			if s_emJogo='1' then
				s_hexa1 <= "00" & s_vidas;
				s_hexa2 <= "0000";
			else
				s_hexa1 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_pontos)) rem 10, 4));
				s_hexa2 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_pontos)) / 10, 4));
				end if;
	 end process;
	
    displayOne: hexa7seg
        port map(
            hexa => s_hexa1,
            enable => '1',
            sseg => display1
        );

    displayTwo: hexa7seg
        port map(
            hexa => s_hexa2,
            enable => s_fimJogo,
            sseg => display2
        );

    estado7s: estado7seg
        port map(
            estado => s_estado,
            sseg   => db_estado
        );

    s_not_fim_vidas <= not s_fim_vidas;

    leds        <= s_tatus;
    fimDeJogo   <= s_fimJogo;
    pontuacao   <= s_pontos;
    vidas       <= s_vidas;
    db_jogadaFeita  <= s_tem_jogada;
    db_jogadaValida <= s_jogada_valida;
    db_timeout      <= s_timeout_TMR;

end architecture;
   
