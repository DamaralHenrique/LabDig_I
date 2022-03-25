library ieee;
use ieee.std_logic_1164.all;

entity testeHL is
    port(
	 botao : in std_logic;
	 led : out std_logic;
	 display : out std_logic_vector(6 downto 0)
	 );
end entity;

architecture HL_arc of testeHL is
begin
    led <= botao;
    display <= "0011001" when botao = '1' else "0000000";
end architecture;


