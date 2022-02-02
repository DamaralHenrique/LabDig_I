--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 3 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/01/2022  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
    port ( 
        clock     : in  std_logic; 
        reset     : in  std_logic; 
        iniciar   : in  std_logic;
        fimC      : in  std_logic;
        jogada    : in  std_logic;
        igual     : in  std_logic; -- Sinal que indica que os dados comparados sao iguais
        zeraC     : out std_logic;
        contaC    : out std_logic;
        zeraR     : out std_logic;
        carregaR  : out std_logic;
        pronto    : out std_logic;
        acertou   : out std_logic; -- Sinal que indica que todos os dados da memoria foram acertados
        errou     : out std_logic; -- Sinal que indica que ao menos um dado da memoria foi errado
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm of unidade_controle is
    -- Substituicao do estado "fim" pelos estados "acerto" e "erro"
    -- "acerto" -> Ao fim da contagem, acertou todos os dados da memoria
    -- "erro" -> Errou um dos dados da memoria
    type t_estado is (inicial, preparacao, esperaJogada, registra, comparacao, proximo, acerto, erro); -- Declaração dos estados
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset) -- Processo sensível à mudança do clock e reset
    begin
        if reset='1' then -- Reset possui preferência sobre o clock e é ativo alto
            Eatual <= inicial;
        elsif clock'event and clock = '1' then -- Ocorre na borda de subida do clock
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    -- Aqui foram adicionadas as transicoes entre os novos estados
    Eprox <=
        inicial      when  Eatual=inicial and iniciar='0' else
        preparacao   when  Eatual=inicial and iniciar='1' else
        esperaJogada when  Eatual=preparacao else
        esperaJogada when  Eatual=esperaJogada and jogada='0' else -- Mantém o estado caso a jogada não foi realizada
        registra     when  Eatual=esperaJogada and jogada='1' else -- Avança o estado se a jogada for feita
        comparacao   when  Eatual=registra else
        proximo      when  Eatual=comparacao and fimC='0' and igual='1' else -- Continua se os dados forem iguais e ainda nao comparou todos os dados
        acerto       when  Eatual=comparacao and fimC='1' and igual='1' else -- Se todos os dados forem comparados e forem iguais, vai para p estado de acerto
        erro         when  Eatual=comparacao and igual='0' else -- Se os dados comparados nao forem iguais, vai para o estado de erro
        esperaJogada when  Eatual=proximo else
        erro         when  Eatual=erro and iniciar='0' else -- Mantém no estado final de erro até ser iniciado novamente
        acerto       when  Eatual=acerto and iniciar='0' else -- Mantém no estado final de acerto até ser iniciado novamente
        inicial      when  (Eatual=erro or Eatual=acerto) and iniciar='1' else -- Volta para o estado de preparação após iniciar novamente
        inicial;

    -- logica de saída (maquina de Moore)
    -- As saídas correspondentes recebem 1 nos estados declarados, e 0 caso contrário
    with Eatual select
        zeraC <=      '1' when preparacao,
                      '0' when others;
    
    with Eatual select
        zeraR <=      '1' when inicial | preparacao,
                      '0' when others;
    
    with Eatual select
        carregaR <=   '1' when registra,
                      '0' when others;

    with Eatual select
        contaC <=     '1' when proximo,
                      '0' when others;
    
    with Eatual select
        pronto <=     '1' when acerto | erro,
                      '0' when others;
    
    with Eatual select
        acertou <=    '1' when acerto,
                      '0' when others;
    
    with Eatual select
        errou <=      '1' when erro,
                      '0' when others;

    -- saida de depuracao (db_estado)
    -- Adicao da saida para o estado de "esperaJogada"
    with Eatual select
        db_estado <= "0000" when inicial,      -- 0
                     "0001" when preparacao,   -- 1
                     "0100" when registra,     -- 4
                     "0101" when comparacao,   -- 5
                     "0110" when proximo,      -- 6
                     "1000" when esperaJogada, -- 8
                     "1010" when acerto,       -- A
                     "1110" when erro,         -- E
                     "1111" when others;       -- F
end fsm;
