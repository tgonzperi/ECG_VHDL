----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/04/2020 01:42:01 PM
-- Design Name:
-- Module Name: buffers - Behavioral
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

ENTITY buffers IS

	GENERIC (
		CONSTANT selector_width : INTEGER := 4;
 
		N : INTEGER := 24;
		address_width : INTEGER := 7;
		buffer_fir_width : INTEGER;
		buffer_iir_width : INTEGER;
		buffer_fir2_width : INTEGER
	);
	PORT (
		clk : IN std_logic;
		incrAddress, initAddress : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);
		
		processingDone : OUT std_logic;
		address_output : OUT std_logic_vector(address_width - 1 DOWNTO 0);
		v_value, h_coef : OUT std_logic_vector(N - 1 DOWNTO 0)
	);
END buffers;

ARCHITECTURE Behavioral OF buffers IS

	TYPE t_buffer IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(N - 1 DOWNTO 0);

	SIGNAL buffer_fir : t_buffer(buffer_fir_width DOWNTO 0);
	SIGNAL buffer_iir_r : t_buffer(buffer_iir_width DOWNTO 0);
	SIGNAL buffer_iir : t_buffer(buffer_iir_width DOWNTO 0);
	SIGNAL buffer_fir2 : t_buffer(buffer_fir2_width DOWNTO 0);

	SIGNAL buffer_fir_coef : t_buffer(buffer_fir_width DOWNTO 0);
	SIGNAL buffer_iir_r_coef : t_buffer(buffer_iir_width DOWNTO 0);
	SIGNAL buffer_iir_coef : t_buffer(buffer_iir_width DOWNTO 0);
	SIGNAL buffer_fir2_coef : t_buffer(buffer_fir2_width DOWNTO 0);
 
	SIGNAL s_address : unsigned(address_width - 1 DOWNTO 0);
 
BEGIN
	processingDone <= '0';
 
	address_generator : PROCESS (clk) IS
	BEGIN
		IF (initAddress = '1') THEN
			s_address <= (OTHERS => '0');
		ELSIF (RISING_EDGE(clk) AND incrAddress = '1') THEN
			s_address <= s_address + 1;
		END IF;
 
		IF (s_address = (2 ** address_width - 1)) THEN
			processingDone <= '1';
		END IF;
	END PROCESS address_generator;

	buffer_selector : PROCESS (selector) IS
	BEGIN
		IF (unsigned(selector) = 0) THEN
			v_value <= buffer_fir(to_integer(s_address));
			h_coef <= buffer_fir_coef(to_integer(s_address));
		ELSIF (unsigned(selector) = 1) THEN
			v_value <= buffer_iir_r(to_integer(s_address));
			h_coef <= buffer_iir_r_coef(to_integer(s_address));
		ELSIF (unsigned(selector) = 2) THEN
			v_value <= buffer_iir(to_integer(s_address));
			h_coef <= buffer_iir_coef(to_integer(s_address));
		ELSIF (unsigned(selector) = 3) THEN
			v_value <= buffer_fir2(to_integer(s_address));
			h_coef <= buffer_fir2_coef(to_integer(s_address));
		END IF;
	END PROCESS buffer_selector;

	address_output <= std_logic_vector(s_address);

END Behavioral;