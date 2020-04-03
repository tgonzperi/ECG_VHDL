LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY FSM_FIR IS

	PORT (
		clk, rst : IN std_logic;
		valid, processingDone : IN std_logic;
		filtres_done, OutRecursive : IN std_logic;
		loadShift, initAddress, incAddress, initSum, loadSum, loadOutput : OUT std_logic
	);
END FSM_FIR;

ARCHITECTURE arch_FSM_FIR OF FSM_FIR IS

	TYPE FSM_state IS (WAIT_SAMPLE, STORE, PROCESSING_LOOP, OUTPUT, WAIT_END_SAMPLE);

	SIGNAL current_state, next_state : FSM_state := WAIT_SAMPLE;
	SIGNAL aux_selADDSUB : std_logic_vector(1 DOWNTO 0);
BEGIN
	curr_state : PROCESS (clk, rst) IS
	BEGIN
		IF (rst = '1') THEN
			current_state <= WAIT_SAMPLE;
		ELSIF (RISING_EDGE(clk)) THEN
			current_state <= next_state;
		END IF;
	END PROCESS curr_state;

	nxt_state : PROCESS (current_state, valid, processingDone) IS
	BEGIN
		loadShift <= '0';
		initAddress <= '0';
		incAddress <= '0';
		initSum <= '0';
		loadSum <= '0';
		loadOutput <= '0';

		CASE current_state IS
			WHEN WAIT_SAMPLE =>
				IF valid = '1' THEN
					initSum <= '1';
					initAddress <= '1';
					next_state <= STORE;
				ELSE
					next_state <= WAIT_SAMPLE;
				END IF;

			WHEN STORE =>
				loadShift <= '1';
				next_state <= PROCESSING_LOOP;
				initSum <= '1';
				initAddress <= '1';

			WHEN PROCESSING_LOOP =>
				IF processingDone = '0' THEN
					incAddress <= '1';
					loadSum <= '1';
				ELSE
					next_state <= OUTPUT;
					initAddress <= '1';
				END IF;

			WHEN OUTPUT =>
				loadOutput <= '1';
				initAddress <= '1';
				IF (filtres_done = '1') THEN
					next_state <= WAIT_END_SAMPLE;
				ELSIF (OutRecursive = '1') THEN
						next_state <= PROCESSING_LOOP;
				ELSE
					next_state <= STORE;
				END IF;

			WHEN WAIT_END_SAMPLE =>
				IF valid = '0' THEN
					next_state <= WAIT_SAMPLE;
				ELSE
					next_state <= WAIT_END_SAMPLE;
				END IF;
		END CASE;

	END PROCESS nxt_state;
END ARCHITECTURE;
