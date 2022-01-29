--------------------------------------------------------------------
-- Arquivo   : unidade_controle_desafio.vhd
-- Projeto   : Experiencia 3 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle adaptada para o desafio, com
--             a adicao de sinais de saida "acertou" e "errou"
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle_desafio is 
    port ( 
        clock     : in  std_logic; 
        reset     : in  std_logic; 
        iniciar   : in  std_logic;
        fimC      : in  std_logic;
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

architecture fsm of unidade_controle_desafio is
    -- Substituicao do estado "fim" pelos estados "acerto" e "erro"
    -- "acerto" -> Ao fim da contagem, acertou todos os dados da memoria
    -- "erro" -> Errou um dos dados da memoria
    type t_estado is (inicial, preparacao, registra, comparacao, proximo, acerto, erro); -- Declaração dos estados
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
        inicial     when  Eatual=inicial and iniciar='0' else
        preparacao  when  Eatual=inicial and iniciar='1' else
        registra    when  Eatual=preparacao else
        comparacao  when  Eatual=registra else
        proximo     when  Eatual=comparacao and fimC='0' and igual='1' else -- Continua se os dados forem iguais e ainda nao comparou todos os dados
        acerto      when  Eatual=comparacao and fimC='1' and igual='1' else -- Se todos os dados forem comparados e forem iguais, vai para p estado de acerto
        erro        when  Eatual=comparacao and igual='0' else -- Se os dados comparados nao forem iguais, vai para o estado de erro
        registra    when  Eatual=proximo else
        inicial     when  Eatual=erro or Eatual=acerto else -- Volta para o estado inicial apos o estado de erro ou acerto
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
    
    -- Substituicao do estado "fim" pelos estados "acerto" e "erro"
    with Eatual select
        pronto <=     '1' when acerto | erro,
                      '0' when others;
    
    -- Adicao dos novos sinais de saida "acertou" e "errou"
    with Eatual select
        acertou <=    '1' when acerto,
                      '0' when others;
    
    with Eatual select
        errou <=      '1' when erro,
                      '0' when others;

    -- saida de depuracao (db_estado)
    -- Adicao das saidas para os estados de "acerto" e "erro"
    with Eatual select
        db_estado <= "0000" when inicial,     -- 0
                     "0001" when preparacao,  -- 1
                     "0100" when registra,    -- 4
                     "0101" when comparacao,  -- 5
                     "0110" when proximo,     -- 6
                     "1010" when acerto,      -- A
                     "1110" when erro,        -- E
                     "1111" when others;      -- F
end fsm;
