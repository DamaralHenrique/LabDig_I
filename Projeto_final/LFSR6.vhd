-----------------------------------------------------------------
-- Arquivo   : geradorJogadas.vhd
-- Projeto   : Tapa no tatu
-----------------------------------------------------------------
-- Descricao : gerador de códigos de 6 bits não nulos
-----------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/03/2022  1.0     Henrique Matheus  versao inicial
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity LFSR6 is
  Port (Clk, Rst: in std_logic;
        output: out std_logic_vector (5 downto 0));
end LFSR6;

architecture LFSR6_beh of LFSR6 is
  signal Currstate, Nextstate: std_logic_vector (5 downto 0);
  signal feedback: std_logic;
begin

  StateReg: process (Clk,Rst)
  begin
    if (Rst = '1') then
      Currstate <= (0 => '1', others =>'0');
    elsif (Clk = '1' and Clk'EVENT) then
      Currstate <= Nextstate;
    end if;
  end process;
  
  feedback <= Currstate(4) xor Currstate(3) xor Currstate(2) xor Currstate(0);
  Nextstate <= feedback & Currstate(5 downto 1);
  output <= Currstate;

end architecture;
