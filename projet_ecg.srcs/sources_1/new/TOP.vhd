----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/11/2020 09:47:50 AM
-- Design Name:
-- Module Name: TOP - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
  GENERIC (
    CONSTANT selector_width : INTEGER := 2;
    N : INTEGER := 24;
    n_out : INTEGER := 24;

    address_width : INTEGER := 7;
    buffer_fir_width : INTEGER := 128;
    buffer_iir_width : INTEGER := 3;
    buffer_fir2_width : INTEGER := 109
  );
  PORT(
  clk, rst : IN std_logic;
  inputSample : IN std_logic_vector(N - 1 downto 0);
  valid : IN std_logic;

  OutputSamle : OUT std_logic_vector(n_out - 1 DOWNTO 0)
  );
end TOP;

architecture Behavioral of TOP is
  COMPONENT TOP_FIR_FSM IS

  GENERIC (
    CONSTANT selector_width : INTEGER := 2;
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

      loadOutput : OUT std_logic;
  		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
  	);
  END COMPONENT;

  COMPONENT FSM_Filtres IS

  	PORT (
  		clk, rst : IN std_logic;
  		loadOutput : IN std_logic;
  		filtres_done : OUT std_logic
  	);
  END COMPONENT;

  signal s_selector : std_logic_vector(selector_width - 1 downto 0);
  signal s_filtres_done : std_logic;
  signal s_loadOutput : std_logic;
begin

inst_FSM_Filtres : FSM_Filtres
  port map(
  clk => clk,
  rst => rst,
  loadOutput => s_loadOutput,
  filtres_done => s_filtres_done
  );

inst_TOP_FIR_FSM : TOP_FIR_FSM
  port map(
    clk => clk,
    rst => rst,
    selector => s_selector,
    valid => valid,
    filtres_done => s_filtres_done
  )

end Behavioral;
