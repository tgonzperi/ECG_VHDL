LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FSM_Filtres IS

	PORT (
		clk, rst : IN std_logic;
		loadOutput : IN std_logic;
		filtres_done : OUT std_logic
	);
END FSM_Filtres;

ARCHITECTURE arch_FSM_Filtres OF FSM_Filtres IS

	TYPE FSM_state IS (FIR1, IIR_R, IIR, FIR2);

	SIGNAL current_state, next_state : FSM_state := FIR1;
	SIGNAL aux_selADDSUB : std_logic_vector(1 DOWNTO 0);
BEGIN
	curr_state : PROCESS (clk, rst) IS
	BEGIN
		IF (rst = '1') THEN
			current_state <= FIR1;
		ELSIF (RISING_EDGE(clk)) THEN
			current_state <= next_state;
		END IF;
	END PROCESS curr_state;

	nxt_state : PROCESS (current_state, loadOutput) IS
	BEGIN
		filtres_done <= '0';

		CASE current_state IS
			WHEN FIR1 => 
				IF loadOutput = '1' THEN
					next_state <= IIR_R;
				ELSE
					next_state <= FIR1;
				END IF;

			WHEN IIR_R => 
				IF loadOutput = '1' THEN
					next_state <= IIR;
				ELSE
					next_state <= IIR_R;
				END IF;

			WHEN IIR => 
				IF loadOutput = '1' THEN
					next_state <= FIR2;
				ELSE
					next_state <= IIR;
				END IF;
			WHEN FIR2 => 
				filtres_done <= '1';
				IF loadOutput = '1' THEN
					next_state <= FIR1;
				ELSE
					next_state <= FIR2;
				END IF;
		END CASE;

	END PROCESS nxt_state;
END ARCHITECTURE;