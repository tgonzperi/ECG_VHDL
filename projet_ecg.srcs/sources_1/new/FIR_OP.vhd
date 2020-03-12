----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 02/26/2020 11:35:34 AM
-- Design Name:
-- Module Name: FIR_OP - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY accumulator IS
	GENERIC (
		N : INTEGER := 24;
		n_out : INTEGER := 24
	);
	PORT (
		clk : IN std_logic;
		initSum, loadSum, loadOutput : IN std_logic;
		v_value, h_coef : IN std_logic_vector(N - 1 DOWNTO 0);

		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
	);
END accumulator;

ARCHITECTURE Behavioral OF accumulator IS

	--type v_fir_first is ARRAY(0 to 128) of std_logic_vector(N-1 downto 0);
	--type v_fir_second is ARRAY(0 to 10) of std_logic_vector(N-1 downto 0);
	--type v_iir_no_recursive is ARRAY(0 to 2) of std_logic_vector(N-1 downto 0);
	--type v_iir_recursive is ARRAY(0 to 2) of std_logic_vector(N-1 downto 0);
	SIGNAL buff, w_mult : signed(n_out - 1 DOWNTO 0);

BEGIN
	w_mult <= (signed(v_value) * signed(h_coef));

	mux_sum : PROCESS (clk) IS
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (initSum = '1') THEN
				buff <= (OTHERS => '0');
			ELSIF (loadSum = '1') THEN
				buff <= buff + w_mult;
			END IF;
		END IF;
	END PROCESS mux_sum;

	accOutput <= std_logic_vector(buff) WHEN (RISING_EDGE(clk) AND loadOutput = '1');

END Behavioral;
