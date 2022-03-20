-------------------------------------------------------------------
-- Arquivo   : pontuacao.vhd
-- Projeto   : Tapa no Tatu
-------------------------------------------------------------------
-- Descricao : Contador da pontuacao
--             Aumenta a cada vez que acerta o tatu
--             Saidas: numero de pontos em binario
-------------------------------------------------------------------

entity pontuacao is
	generic (
        constant limMax: integer := 100 -- modulo do contador (100 como valor provisorio)
    );
	port (
        clock   : in  std_logic;
        clr     : in  std_logic;
        enp     : in  std_logic;
		acertou : in  std_logic;
        pontos  : out std_logic_vector (natural(ceil(log2(real(limMax)))) - 1 downto 0) -- pokde ser menor que 
   );
end pontuacao;

architecture comportamental of pontuacao is
    signal contaPontos: integer range 0 to limMax - 1; -- Declaração do sinal interno de contagem
begin
  
    process (clock)
    begin
    
        if clock'event and clock = '1' then -- Se o clock altera o sinal para 1 (1)
            
			if clr = '0' then
			    contaPontos <= 0;    -- Se o clear foi ativado (Ativo baixo), reseta a contagem (2)
            
			elsif enp = '1' and acertou = '1' then 
                if contaPontos = limMax - 1 then
				    contaPontos <= 0;  -- Se a contagem já atingiu o maximo, a contagem é resetada (3)
                
				else
				    contaPontos <= contaPontos + 1; -- senão, incrementa a contagem
                end if; -- Fim do if 3
            
			else
			    contaPontos <= contaPontos; -- senão, mantém contagem anterior
            
			end if; -- Fim do if 2
        
		end if; -- Fim do if 1

    end process;

    -- saida pontos
    pontos <= std_logic_vector(to_unsigned(contaPontos, pontos'length)); -- Saida Q recebe o valor do contador convertido para vetor binário

end comportamental;
