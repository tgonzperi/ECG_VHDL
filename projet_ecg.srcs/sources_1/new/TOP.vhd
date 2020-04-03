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
    n_out : INTEGER := 48;

    address_width : INTEGER := 7;
    buffer_fir_width : INTEGER := 129;
    buffer_iir_width : INTEGER := 3;
    buffer_fir2_width : INTEGER := 11
  );
  PORT(
  clk, rst : IN std_logic;
  inputSample : IN std_logic_vector(N - 1 downto 0);
  valid : IN std_logic;

  OutputSample : OUT std_logic_vector(n_out - 1 DOWNTO 0)
  );
end TOP;

architecture Behavioral of TOP is
  COMPONENT TOP_FIR_FSM IS

  GENERIC (
    CONSTANT selector_width : INTEGER := 2;
    N : INTEGER := 24;
    n_out : INTEGER;

    address_width : INTEGER := 7;
    buffer_fir_width : INTEGER := 129;
    buffer_iir_width : INTEGER := 3;
    buffer_fir2_width : INTEGER := 11
  );
  	PORT (
    clk, rst : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);
    valid, filtres_done, OutRecursive : in std_logic;
    inputSample : in std_logic_vector(N - 1 downto 0);

    loadOutput : OUT std_logic;
		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0)
  	);
  END COMPONENT;

  COMPONENT FSM_Filtres IS

  	PORT (
  		clk, rst : IN std_logic;
  		loadOutput : IN std_logic;
  		filtres_done, OutRecursive : OUT std_logic;
      OutputValid : OUT std_logic;
      selector : OUT std_logic_vector(selector_width - 1 downto 0)
  	);

  END COMPONENT;

  signal s_selector : std_logic_vector(selector_width - 1 downto 0);
  signal s_filtres_done, s_OutRecursive : std_logic;
  signal s_loadOutput : std_logic;
  signal s_OutputValid : std_logic;
  signal s_OutputSample : std_logic_vector(n_out - 1 downto 0);
begin

inst_FSM_Filtres : FSM_Filtres
  port map(
  clk => clk,
  rst => rst,
  loadOutput => s_loadOutput,
  filtres_done => s_filtres_done,
  OutRecursive => s_OutRecursive,
  selector => s_selector,
  OutputValid => s_OutputValid
  );

inst_TOP_FIR_FSM : TOP_FIR_FSM
generic map(

N => N,
n_out => n_out,

address_width => address_width,
buffer_fir_width => buffer_fir_width,
buffer_iir_width => buffer_iir_width,
buffer_fir2_width => buffer_fir2_width
)
  port map(
    clk => clk,
    rst => rst,
    selector => s_selector,
    inputSample => inputSample,
    loadOutput => s_loadOutput,
    valid => valid,
    filtres_done => s_filtres_done,
    OutRecursive => s_OutRecursive,
    accOutput => s_OutputSample
  );

  OutputSample <= s_OutputSample when (RISING_EDGE(clk) and s_OutputValid = '1');

end Behavioral;
