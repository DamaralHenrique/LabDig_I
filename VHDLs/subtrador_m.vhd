-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : contador_m.vhd
-- Projeto   : Experiencia 4 - Desenvolvimento de Projeto de 
--                             Circuitos Digitais em FPGA
-------------------------------------------------------------------------
-- Descricao : contador binario, modulo m, com parametro M generic,
--             sinais para clear assincrono (zera_as) e sincrono (zera_s)
--             e saidas de fim e meio de contagem
-- 
--             calculo do numero de bits do contador em funcao do modulo:
--             N = natural(ceil(log2(real(M))))
--
-- Exemplo de instanciacao: contador módulo 50
--             CONT50: contador_m 
--                     generic map ( M=> 50 )
--                     port map ( ...
--             
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao
--     08/06/2020  1.1     Edson Midorikawa  revisao e melhoria de codigo 
--     09/09/2020  1.2     Edson Midorikawa  revisao 
--     30/01/2022  2.0     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity subtrador_m is
    port (
        clock      : in  std_logic;
        load       : in  std_logic;
        load_value : in integer;
        conta      : in  std_logic;
        Q          : out integer;
        fim     : out std_logic
    );
end entity subtrador_m;

architecture comportamental of subtrador_m is
    signal IQ: integer;
begin
  
    process (clock,load,conta,IQ)
    begin
        if load='1' then    IQ <= load_value;   
        elsif rising_edge(clock) then
            if conta='1' then 
                if IQ=0 then IQ <= 0; 
                else         IQ <= IQ - 1000000; 
                end if;
            else             IQ <= IQ;
            end if;
        end if;
    end process;

    -- saida fim
    fim <= '1' when IQ=0 else
           '0';

    Q <= IQ;

end architecture comportamental;
