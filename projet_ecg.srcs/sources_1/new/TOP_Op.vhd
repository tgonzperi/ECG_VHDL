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

ENTITY TOP_Op IS

	GENERIC (
		CONSTANT selector_width : INTEGER := 4;
		N : INTEGER := 24;
		n_out : INTEGER := 24;
		
		address_width : INTEGER := 7;
		buffer_fir_width : INTEGER := 128;
		buffer_iir_width : INTEGER := 3;
		buffer_fir2_width : INTEGER := 109
	);
	PORT (
		clk : IN std_logic;
		incrAddress, initAddress : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);

		initSum, loadSum, loadOutput : IN std_logic;
		sumSelect : IN std_logic;

		processingDone : OUT std_logic;
		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
	);
END TOP_Op;

ARCHITECTURE Behavioral OF TOP_Op IS

signal s_v_value, s_h_coef : std_logic_vector(N - 1 DOWNTO 0);

COMPONENT accumulator IS
	GENERIC (
		N : INTEGER := 24;
		n_out : INTEGER := 24
	);
	PORT (
		clk : IN std_logic;
		initSum, loadSum, loadOutput : IN std_logic;
		v_value, h_coef : IN std_logic_vector(N - 1 DOWNTO 0);
		sumSelect : IN std_logic;

		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT buffers IS
	GENERIC (
		CONSTANT selector_width : INTEGER := 4;

		N : INTEGER := 24;
		address_width : INTEGER := 7;
		buffer_fir_width : INTEGER := 128;
		buffer_iir_width : INTEGER := 3;
		buffer_fir2_width : INTEGER := 109
	);
	PORT (
		clk : IN std_logic;
		incrAddress, initAddress : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);

		processingDone : OUT std_logic;
		v_value, h_coef : OUT std_logic_vector(N - 1 DOWNTO 0)
	);
END COMPONENT;

BEGIN

Inst_accu : accumulator
	port map(
	clk => clk,
	initSum => initSum,
	loadSum => loadSum,
	loadOutput => loadOutput,
	sumSelect => sumSelect,

	accOutput => accOutput,

	v_value => s_v_value,
	h_coef => s_h_coef
	);

Inst_buffers : buffers
	port map(
	clk => clk,
	incrAddress => incrAddress,
	initAddress => initAddress,
	selector => selector,
	processingDone => processingDone,
	v_value => s_v_value,
	h_coef => s_h_coef
	);

	
END Behavioral;