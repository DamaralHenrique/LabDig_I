------------------------------------------------------------------
-- Arquivo   : contador_163.vhd
-- Projeto   : Experiencia 01 - Primeiro Contato com VHDL
------------------------------------------------------------------
-- Descricao : contador binario hexadecimal (modulo 16) 
--             similar ao CI 74163
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     29/12/2020  1.0     Edson Midorikawa  criacao
--     07/01/2022  2.0     Edson Midorikawa  revisao do componente
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_160 is
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
end contador_160;

architecture comportamental of contador_160 is
    signal IQ: integer range 0 to 15;
begin
  
    -- contagem
    process (clock, clr) -- Processo sensível a mudança do CLEAR
    begin
    
        if clr='0' then -- CLEAR assíncrino e ativo baixo
			  IQ <= 0;
		  else
			  if clock'event and clock='1' then 
					if ld='0' then 
						if to_integer(unsigned(D)) > 9 then -- Se o valor for maior que 9 (máximo)
							IQ <= IQ; -- Mantém valor antigo
						else -- Senão
							IQ <= to_integer(unsigned(D)); -- Carrega valor de D
						end if;	
					elsif ent='1' and enp='1' then 
						 if IQ=9 then IQ <= 0;  
						 else          IQ <= IQ + 1; 
						 end if; 
					else              IQ <= IQ; 
					end if; 
			  end if; 
		  end if;
    end process;

    -- saida rco
    rco <= '1' when IQ=9 and ent='1' else -- Quando o valor da contagem chega em 9 e ENT está ativado, RCO ativa
           '0'; 

    -- saida Q
    Q <= std_logic_vector(to_unsigned(IQ, Q'length)); 

end comportamental;
