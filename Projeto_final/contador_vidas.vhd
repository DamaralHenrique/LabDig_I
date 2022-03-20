-------------------------------------------------------------------
-- Arquivo   : contador_vidas.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------
-- Descricao : Contador da vida do jogador
--             Diminui a cada vez que perde ponto
--             Saidas: numero de vidas em binario e se acabaram
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity contador_vidas is
	generic (
        constant nVidas: integer := 3 -- modulo do contador
    );
	
	port (
        clock    : in  std_logic;
        clr      : in  std_logic;
        enp      : in  std_logic;
		acertou  : in std_logic;
        vidasBin : out std_logic_vector (natural(ceil(log2(real(nVidas)))) - 1 downto 0);
        fimVidas : out std_logic 
   );
end contador_vidas;

architecture comportamental of contador_vidas is
    signal vida: integer range nVidas - 1 downto 0; -- Declaração do sinal interno de contagem
begin
  
    process (clock)
    begin
    
        if clock'event and clock = '1' then -- Se o clock altera o sinal para 1 (1)
            
			if clr = '0' then
			    vida <= nVidas - 1;    -- Se o clear foi ativado (Ativo baixo), reseta a contagem (2)
            
			elsif enp = '1' and acertou = '0' then 
                if vida = 0 then
				    vida <= nVidas - 1;  -- Se a contagem já atingiu 15, a contagem é resetada (3)
                
				else
				    vida <= vida - 1; -- senão, decrementa a contagem
                end if; -- Fim do if 3
            
			else
			    vida <= vida; -- senão, mantém contagem anterior
            
			end if; -- Fim do if 2
        
		end if; -- Fim do if 1

    end process;

    -- saida fimVidas
    fimVidas <= '1' when vida = 0 else -- rco recebe 1 no final da contagem, com ent ativo alto
                '0'; -- senão, recebe 0

    -- saida vidasBin
    vidasBin <= std_logic_vector(to_unsigned(vida, vidasBin'length)); -- Saida Q recebe o valor do contador convertido para vetor binário

end comportamental;






