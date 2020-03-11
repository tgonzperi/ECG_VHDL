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

ENTITY TOP_FIR_FSM IS

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
		clk, rst : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);
    valid, filtres_done : in std_logic;

		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
	);
END TOP_FIR_FSM;

ARCHITECTURE Behavioral OF TOP_FIR_FSM IS

COMPONENT TOP_Op IS
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

  processingDone : OUT std_logic;
  accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
	);
END COMPONENT;


COMPONENT FSM_FIR IS

PORT (
  clk, rst : IN std_logic;
  valid, processingDone : IN std_logic;
  filtres_done : IN std_logic;
  loadShift, initAddress, incAddress, initSum, loadSum, loadOutput : OUT std_logic
);
END COMPONENT;


signal s_loadShift, s_initAddress, s_incAddress, s_initSum, s_loadSum, s_loadOutput : std_logic;
signal s_processingDone : std_logic;
BEGIN

Inst_accu : TOP_Op
	port map(
	clk => clk,
	initSum => s_initSum,
	loadSum => s_loadSum,
	loadOutput => s_loadOutput,
  incrAddress => s_incAddress,
  initAddress => s_initAddress,
  selector => selector,

  processingDone => s_processingDone,
	accOutput => accOutput
	);

Inst_buffers : FSM_FIR
	port map(
  clk => clk,
  rst => rst,
  valid => valid,
  filtres_done => filtres_done,
	processingDone => s_processingDone,

	initSum => s_initSum,
	loadSum => s_loadSum,
	loadOutput => s_loadOutput,
  incrAddress => s_incAddress,
  initAddress => s_initAddress
	);


END Behavioral;
