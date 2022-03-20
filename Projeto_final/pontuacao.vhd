
-- contador: Manter o antigo tbm pra quando apaga o led,
--           mas devemos  criar um novo q para quando chega a um valor q vai diminuindo
--           (acho q esse valor pode ser uma entrada)

-- comparador: pra ele validar uma jogada agr ele tem q fazer um OR de ANDs das toupeiras.
--     OK      Tipo, se o gabarito for 110000, ele deve retornar 1 pra 100000 e 0 pra 001000, por exemplo.

-- remoção da toupeira: pode ser um novo componente que recebe 2 entradas A e B e faz A - B.
--     OK               Ex: A=0110 e B=0010 então resp=0100. Isso da pra fazer com um XOR, acho.
--                      Esse componente tbm ficará encarregado de informar se depois da remoção se tem toupeira o n (OR simples)

-- pontuação e contaPontos: podem ser contadores, mas talvez tenhamos q criar um específico pra contaPontos,
--                          já q ela vai diminuindo ( ou trocar pra strikes?)

-- entrada aleatória: pensei numa alternativa que eh gerar um número entre 0 e 1,
--                    e em cada faixa (sla 0 - 0,1; 0,1 - 0,2;...) corresponde a uma configuração de toupeira.


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