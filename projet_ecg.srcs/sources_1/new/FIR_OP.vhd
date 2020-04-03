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



	function round_signed (
		constant output_size : natural;
		input                : signed)
		return signed is
		variable result : signed(output_size -1 downto 0);
	begin
		if input(input'length-output_size-1) = '1' then
			result := input(input'length-1 downto input'length-output_size) + 1;
		else
			result := input(input'length-1 downto input'length-output_size);
		end if;
		--VHDL 2008:
		--result := input(input'length-1 downto input'length-output_size) + 1 when input(input'length-output_size-1)='1' else input(input'length-1 downto input'length-output_size);
		return result;
	end round_signed;

	SIGNAL buff, w_mult : signed(2*N - 1 DOWNTO 0);

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

		accOutput <= std_logic_vector(resize(round_signed(N+2,buff),N)) WHEN (RISING_EDGE(clk) AND loadOutput = '1');

END Behavioral;
