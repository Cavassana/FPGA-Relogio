LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

LIBRARY lpm;
USE lpm.all;

ENTITY contadorMOD60 IS
GENERIC 	(	modulo	: IN NATURAL; 		-- define p módulo
				tam_bus	: IN NATURAL); 	-- define o número de bits
	PORT	(	cin		: IN STD_LOGIC ;	-- habilita o contador
				clock		: IN STD_LOGIC ;	
				data		: IN STD_LOGIC_VECTOR (tam_bus-1 DOWNTO 0);	-- entrada do contador
				sclr		: IN STD_LOGIC ;	-- rst em ALTO
				sload		: IN STD_LOGIC ;	-- entrada em paralelo (ajuste)
				updown	: IN STD_LOGIC ;	-- sentido
				cout		: OUT STD_LOGIC ;	-- overflow do contador (habilita próx. contador)
				q			: OUT STD_LOGIC_VECTOR (tam_bus-1 DOWNTO 0)); -- saída
END contadorMOD60;

ARCHITECTURE SYN OF contadorMOD60 IS
-- sinais internos
SIGNAL sub_wire0	: STD_LOGIC ; 							
SIGNAL sub_wire1	: STD_LOGIC_VECTOR (tam_bus-1 DOWNTO 0);
-- declara a megafunction contador criada no megawizard modulo 60
COMPONENT lpm_counter
GENERIC (	lpm_direction		: STRING;	-- direção (não utilizado)
				lpm_modulus			: NATURAL;	-- módulo
				lpm_port_updown	: STRING;	-- sentido
				lpm_type				: STRING;	-- tipo da megafunction
				lpm_width			: NATURAL);	-- número de bits	
	PORT (	cin		: IN STD_LOGIC ;										-- habilita o contador
				clock		: IN STD_LOGIC ;
				data		: IN STD_LOGIC_VECTOR (tam_bus-1 DOWNTO 0);	-- entrada do contador
				sclr		: IN STD_LOGIC ;										-- rst em ALTO							
				cout		: OUT STD_LOGIC ;										-- saida do overflow
				q			: OUT STD_LOGIC_VECTOR(tam_bus-1 DOWNTO 0);	-- saida do contador
				sload		: IN STD_LOGIC ;										-- entrada em paralelo (ajuste)
				updown	: IN STD_LOGIC );										-- sentido
END COMPONENT;	

BEGIN
	cout    <= sub_wire0;						-- overflow do contador 
	q    <= sub_wire1(tam_bus-1 DOWNTO 0);	-- saída
-- chama a função contador módulo 60
LPM_COUNTER_component : LPM_COUNTER
GENERIC MAP (	lpm_direction		 => "UNUSED",
					lpm_modulus		 	=> modulo,
					lpm_port_updown 	=> "PORT_USED",
					lpm_type 			=> "LPM_COUNTER",
					lpm_width 			=> tam_bus)
	PORT MAP (	cin 		=> cin,
					clock	 	=> clock,
					data 		=> data,
					sclr 		=> sclr,
					sload 	=> sload,
					updown 	=> updown,
					cout 		=> sub_wire0,
					q 			=> sub_wire1);

END SYN;