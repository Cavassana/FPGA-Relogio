library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

ENTITY decode7seg_rel IS 
    PORT(seletor					: IN STD_LOGIC_VECTOR(1 downto 0);	-- seleciona decod. para unidade ou dezena
			entrada_display		: IN STD_LOGIC_VECTOR(4 downto 0); 	-- entrada do display <= saída do respectivo contador
			a, b, c, d, e, f, g 	: OUT STD_LOGIC);							-- saída 
END decode7seg_rel;

ARCHITECTURE teste_decode7seg_rel OF decode7seg_rel IS 

BEGIN 	

PROCESS(entrada_display)
	VARIABLE segmentos : STD_LOGIC_VECTOR(0 TO 6); 
BEGIN
	IF seletor = "01" THEN -- "01" decodifica para display de unidades
		CASE entrada_display IS 
			WHEN "00000" => segmentos := "1111110";--00
			WHEN "00001" => segmentos := "0110000";--01
			WHEN "00010" => segmentos := "1101101";--02
			WHEN "00011" => segmentos := "1111001";--03
			WHEN "00100" => segmentos := "0110011";--04
			WHEN "00101" => segmentos := "1011011";--05
			WHEN "00110" => segmentos := "1011111";--06
			WHEN "00111" => segmentos := "1110000";--07
			WHEN "01000" => segmentos := "1111111";--08
			WHEN "01001" => segmentos := "1110011";--09
			WHEN "01010" => segmentos := "1111110";--10
			WHEN "01011" => segmentos := "0110000";--11
			WHEN "01100" => segmentos := "1101101";--12
			WHEN "01101" => segmentos := "1111001";--13
			WHEN "01110" => segmentos := "0110011";--14
			WHEN "01111" => segmentos := "1011011";--15
			WHEN "10000" => segmentos := "1011111";--16
			WHEN "10001" => segmentos := "1110000";--17
			WHEN "10010" => segmentos := "1111111";--18
			WHEN "10011" => segmentos := "1110011";--19
			WHEN "10100" => segmentos := "1111110";--20
			WHEN "10101" => segmentos := "0110000";--21
			WHEN "10110" => segmentos := "1101101";--22
			WHEN "10111" => segmentos := "1111001";--23
			WHEN OTHERS => segmentos := "0000000";
		END CASE;
	ELSIF seletor = "10" THEN -- "10" decodifica para display de dezenas
		CASE entrada_display IS 
			WHEN "00000" => segmentos := "1111110";--00
			WHEN "00001" => segmentos := "1111110";--01
			WHEN "00010" => segmentos := "1111110";--02
			WHEN "00011" => segmentos := "1111110";--03
			WHEN "00100" => segmentos := "1111110";--04
			WHEN "00101" => segmentos := "1111110";--05
			WHEN "00110" => segmentos := "1111110";--06
			WHEN "00111" => segmentos := "1111110";--07
			WHEN "01000" => segmentos := "1111110";--08
			WHEN "01001" => segmentos := "1111110";--09
			WHEN "01010" => segmentos := "0110000";--10
			WHEN "01011" => segmentos := "0110000";--11
			WHEN "01100" => segmentos := "0110000";--12
			WHEN "01101" => segmentos := "0110000";--13
			WHEN "01110" => segmentos := "0110000";--14
			WHEN "01111" => segmentos := "0110000";--15
			WHEN "10000" => segmentos := "0110000";--16
			WHEN "10001" => segmentos := "0110000";--17
			WHEN "10010" => segmentos := "0110000";--18
			WHEN "10011" => segmentos := "0110000";--19
			WHEN "10100" => segmentos := "1101101";--20
			WHEN "10101" => segmentos := "1101101";--21
			WHEN "10110" => segmentos := "1101101";--22
			WHEN "10111" => segmentos := "1101101";--23
			WHEN "11000" => segmentos := "1101101";--24
			WHEN "11001" => segmentos := "1101101";--25
			WHEN "11010" => segmentos := "1101101";--26
			WHEN "11011" => segmentos := "1101101";--27
			WHEN "11100" => segmentos := "1101101";--28
			WHEN "11101" => segmentos := "1101101";--29
			WHEN "11110" => segmentos := "1111001";--30
			WHEN "11111" => segmentos := "1111001";--31
			WHEN OTHERS  => segmentos := "0000000";-- null
		END CASE;
	END IF;
	-- saídas recebem respectivos segmentos
	a <= segmentos(0);
	b <= segmentos(1);
	c <= segmentos(2);
	d <= segmentos(3);
	e <= segmentos(4);
	f <= segmentos(5);
   g <= segmentos(6);
END PROCESS;
END teste_decode7seg_rel;