-- declaração das bibliotecas e pacotes
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;
LIBRARY lpm; -- permite o uso de megafunctions
USE lpm.all;

ENTITY relogioFinal IS 
GENERIC( frequencia	: NATURAL := 250000; 	-- 250khz p/validação
			n 				: INTEGER := 6); 			-- define no. de contadores 
    PORT(clk						: IN STD_LOGIC; 
			rst						: IN STD_LOGIC; 							-- rst em ALTO
			habilita_contador		: IN STD_LOGIC; 							-- permite a contagem (inicia relógio)
			habilita_alarme		: IN STD_LOGIC; 							-- permite gravar horas e minutos
			sentido					: IN STD_LOGIC; 							-- define o sentido
			habilita_paralelo		: IN STD_LOGIC; 							-- permite inserir hr, min e seg
			dado_paralelo			: IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- 5 bits para inserir hr, min e seg.
			sel_1,sel_2,sel_3		: IN STD_LOGIC; 							-- seleciona contador
			overflow					: BUFFER STD_LOGIC;
			buzzer					: OUT STD_LOGIC; 							-- alarme sonoro
			pisca_placa				: OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- leds onboard da placa
			led						: OUT STD_LOGIC_VECTOR(1 TO 8); 		-- leds para testes e validações
			sa,sb,sc,sd,se,sf,sg	: OUT STD_LOGIC_VECTOR(5 downto 0));-- saídas para os displays de 7 segmentos
END relogioFinal;

ARCHITECTURE teste_relogioFinal OF relogioFinal IS 

COMPONENT divisorFrequencia 
GENERIC( frequencia_osc : NATURAL); 
	PORT(	clk	: IN STD_LOGIC;
			pulso	: OUT STD_LOGIC); 
END COMPONENT;

COMPONENT decode7seg_rel
	PORT (seletor					: IN STD_LOGIC_VECTOR(1 downto 0);
			entrada_display		: IN STD_LOGIC_VECTOR(4 downto 0);
			a, b, c, d, e, f, g 	: OUT STD_LOGIC);
END COMPONENT;

COMPONENT contadorMOD60 
GENERIC( modulo	: IN NATURAL; 
			tam_bus	: IN NATURAL); 
	PORT( cin		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			sclr		: IN STD_LOGIC ;
			sload		: IN STD_LOGIC ;
			updown	: IN STD_LOGIC ;
			cout		: OUT STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0));
END COMPONENT;	

COMPONENT contaHora
PORT(	clock		: IN STD_LOGIC ;
		cnt_en	: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		sclr		: IN STD_LOGIC ;
		sload		: IN STD_LOGIC ;
		updown	: IN STD_LOGIC ;
		cout		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (4 DOWNTO 0));
END COMPONENT;

SIGNAL pulso1s						: STD_LOGIC;						-- frequencia de 1hz quando frequencia_osc = 50Mhz
SIGNAL enable						: STD_LOGIC_VECTOR(1 TO n-1);	-- habilita o próximo contador MOD60
-- registradores que guardam a hora e os minutos do alarme
SIGNAL mem_saida_contador_c 	: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL mem_saida_contador_m 	: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL mem_saida_contador_dm	: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
-- registradores de saida dos contadores de modulo 60 e 24
SIGNAL saida_contador_u 		: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL saida_contador_d 		: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL saida_contador_c 		: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL saida_contador_m 		: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL saida_contador_dm		: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
SIGNAL saida_contador_meg 		: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0');
-- entrada do usuario
SIGNAL dado_paralelo_u 			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_paralelo_d			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_paralelo_c 			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_paralelo_m			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_paralelo_dm			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
-- entrada do contador
SIGNAL dado_contador_u 			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_contador_d			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_contador_c 			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_contador_m			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
SIGNAL dado_contador_dm			: STD_LOGIC_VECTOR(4 DOWNTO 0):= (OTHERS => '0');
-- mux de seleção de contador p/ ajuste da hora
SIGNAL sel_mux						: STD_LOGIC_VECTOR(2 DOWNTO 0):= (OTHERS => '0');
SIGNAL ot_mux						: STD_LOGIC_VECTOR(4 downto 0):= (OTHERS => '0'); -- recebe lixo
-- flags de controle do acionamento do alarme
SIGNAL flag 						: STD_LOGIC_VECTOR(3 downto 0):= (OTHERS => '0');

BEGIN 
-- define vetor de selecao
sel_mux <= sel_3 & sel_2 & sel_1;
-- Divisor de frequencia
div_f0:	divisorFrequencia 
GENERIC MAP(frequencia) -- quando 50Mhz => saída <= 1hz
	PORT MAP(clk, pulso1s); 
-- ajuste do relogio
ajuste: PROCESS(habilita_paralelo, habilita_alarme)
	BEGIN
		CASE sel_mux IS
			WHEN "000" => dado_paralelo_u 	<= dado_paralelo;		-- ajusta unid. do segundo 
							  dado_paralelo_d		<= (OTHERS => '0');	-- zera os contadores 
							  dado_paralelo_c		<= (OTHERS => '0');	-- idem 
							  dado_paralelo_m		<= (OTHERS => '0');	-- idem 
							  dado_paralelo_dm 	<= (OTHERS => '0');	-- idem 
			WHEN "001" => dado_paralelo_d 	<= dado_paralelo;		-- ajusta deze. do segundo 
			WHEN "010" => dado_paralelo_c 	<= dado_paralelo; 	-- ajusta unid. do minuto 
			WHEN "011" => dado_paralelo_m 	<= dado_paralelo;		-- ajusta deze. do minuto 
			WHEN "111" => dado_paralelo_dm 	<= dado_paralelo; 	-- ajusta hora 
			WHEN OTHERS => ot_mux <= null; 
		END CASE;
		-- controle da entrada do usuário
		IF habilita_paralelo ='1' THEN 
			IF to_integer(UNSIGNED (dado_paralelo_u)) > 9 THEN dado_contador_u <= (OTHERS => '0');
			ELSE dado_contador_u <= dado_paralelo_u; END IF;
			IF to_integer(UNSIGNED (dado_paralelo_d)) > 5 THEN dado_contador_d <= (OTHERS => '0');
			ELSE dado_contador_d <= dado_paralelo_d; END IF;
			IF to_integer(UNSIGNED (dado_paralelo_c)) > 9 THEN dado_contador_c <= (OTHERS => '0');
			ELSE dado_contador_c <= dado_paralelo_c; END IF;
			IF to_integer(UNSIGNED (dado_paralelo_m)) > 5 THEN dado_contador_m <= (OTHERS => '0');
			ELSE dado_contador_m <= dado_paralelo_m; END IF;
			IF to_integer(UNSIGNED (dado_paralelo_dm)) > 23 THEN dado_contador_dm <= (OTHERS => '0');
			ELSE dado_contador_dm <= dado_paralelo_dm; END IF;
		 END IF;	
END PROCESS ajuste;
-- armazena horas e minutos
mem: PROCESS(habilita_alarme) 
	BEGIN
		IF habilita_alarme = '1' THEN 
			mem_saida_contador_c 	<= saida_contador_c;	
			mem_saida_contador_m 	<= saida_contador_m;	
			mem_saida_contador_dm	<= saida_contador_dm;
		END IF;
END PROCESS mem;		
-- Alarme
testa_unid_min: 	flag(0)<='1' WHEN mem_saida_contador_c = saida_contador_c ELSE '0';
testa_deze_min: 	flag(1)<='1' WHEN mem_saida_contador_m = saida_contador_m ELSE '0';
	 testa_hora: 	flag(2)<='1' WHEN mem_saida_contador_dm = saida_contador_dm ELSE '0';
	 testa_flag: 	flag(3)<='1' WHEN flag(0)='1' AND flag(1) ='1' AND flag(2) ='1' ELSE '0';
-- Display
d_0:	decode7seg_rel -- display da unidade do segundo
		PORT MAP( "01", saida_contador_u, sa(0), sb(0), sc(0), sd(0), se(0), sf(0), sg(0));
d_1:	decode7seg_rel -- display da dezena do segundo
		PORT MAP( "01", saida_contador_d, sa(1), sb(1), sc(1), sd(1), se(1), sf(1), sg(1));	
d_2: decode7seg_rel 	-- display da unidade do minuto
		PORT MAP( "01", saida_contador_c, sa(2), sb(2), sc(2), sd(2), se(2), sf(2), sg(2));		
d_3: decode7seg_rel 	-- display da dezena do minuto
		PORT MAP( "01", saida_contador_m, sa(3), sb(3), sc(3), sd(3), se(3), sf(3), sg(3));	
d_4: decode7seg_rel 	-- display da unidade da hora
		PORT MAP( "01", saida_contador_dm, sa(4), sb(4), sc(4), sd(4), se(4), sf(4), sg(4));
d_5: decode7seg_rel 	-- display da dezena da hora
		PORT MAP( "10", saida_contador_meg, sa(5), sb(5), sc(5), sd(5), se(5), sf(5), sg(5));			
-- Contador
u_c:	contadorMOD60 -- contador da unidade do segundo
	GENERIC MAP(modulo	=> 10, -- define unidade ou dezena
					tam_bus	=>  5) -- define bits
		PORT MAP(cin		=> habilita_contador,	-- se '0' => não conta 
					clock 	=>	pulso1s,					-- 1hz
					data		=> dado_contador_u, 		-- entrada do contador
					sclr		=>	rst,						-- rst = '1'
					sload		=> habilita_paralelo,	-- entrada pararela (ajuste/alarme)
					updown	=> sentido,					-- crescente ou decrescente
					cout		=> enable(1),				-- habilita o próximo
					q			=> saida_contador_u);	-- saída do contador
d_c: 	contadorMOD60 -- contador da dezena do segundo
	GENERIC MAP(modulo	=>  6, 
					tam_bus	=>  5) 
		PORT MAP(cin		=> enable(1),
					clock 	=>	pulso1s,
					data		=> dado_contador_d,
					sclr		=>	rst,
					sload		=> habilita_paralelo,
					updown	=> sentido,
					cout		=> enable(2),
					q			=> saida_contador_d);
c_c:	contadorMOD60 -- contador da unidade do minuto
	GENERIC MAP(modulo	=> 10,
					tam_bus	=>  5)
		PORT MAP(cin		=> enable(2),
					clock 	=>	pulso1s,
					data		=> dado_contador_c,
					sclr		=>	rst,
					sload		=> habilita_paralelo,
					updown	=> sentido,
					cout		=> enable(3),
					q			=> saida_contador_c);	
m_c:	contadorMOD60 -- contador da dezena do minuto
	GENERIC MAP(modulo	=>  6,
					tam_bus	=>  5)
		PORT MAP(cin		=> enable(3),
					clock 	=>	pulso1s,
					data		=> dado_contador_m,
					sclr		=>	rst,
					sload		=> habilita_paralelo,
					updown	=> sentido,
					cout		=> enable(4),
					q			=> saida_contador_m);
dm_c:	contaHora -- contador da unidade da hora
		PORT MAP(cnt_en	=> enable(4), 
					clock 	=>	pulso1s,
					data		=> dado_contador_dm,
					sclr		=>	rst,
					sload		=> habilita_paralelo,
					updown	=> sentido,
					cout		=> enable(5),
					q			=> saida_contador_dm);	
meg_c:contaHora -- contador da dezena da hora
		PORT MAP(cnt_en	=> enable(4), 
					clock 	=>	pulso1s,
					data		=> dado_contador_dm,
					sclr		=>	rst,
					sload		=> habilita_paralelo,
					updown	=> sentido,
					cout		=> overflow,
					q			=> saida_contador_meg);	
-- leds e buzzer
PROCESS(flag, pulso1s)
	VARIABLE count 	: NATURAL RANGE 0 TO 300 := 300;
	VARIABLE count2 	: NATURAL RANGE 0 TO 10 := 0;
	VARIABLE flag1 	: STD_LOGIC;
	BEGIN 
		-- leds para verificação e testes
		IF flag(0)='1' THEN led(1) <= '1'; 
							ELSE led(1) <= '0'; END IF;
		IF flag(1)='1' THEN led(2) <= '1'; 
							ELSE led(2) <= '0'; END IF;
		IF flag(2)='1' THEN led(3) <= '1'; 
							ELSE led(3) <= '0'; END IF;
		--	ALARME
		IF (pulso1s = '1' ) THEN
			IF (flag1 = '1') THEN count := count-1; 
			END IF;
		END IF;		
		-- caso vetor flag <= "111" dispara o alarme
		IF flag(3)='1' THEN 
			count := 300; 
			count2 := 4; 
			flag1 := '1'; 
		END IF;
		IF count >150 AND count2 > 0 AND flag1 = '1' THEN 	-- aciona buzzer e led
			led(8) <= '1';
			buzzer <= '1';
		ELSE																-- desliga buzzer e led
			buzzer <= '0'; 	
			led(8) <= '0';
		END IF;
		IF count = 0 AND count2 > 0 THEN 						-- controle do alarme
			count2:= count2-1;										-- idem
			count := 300; 												-- idem
		END IF;	
		IF count2 = 0 THEN flag1 := '0'; END IF;				-- idem
		
END PROCESS;
END teste_relogioFinal;