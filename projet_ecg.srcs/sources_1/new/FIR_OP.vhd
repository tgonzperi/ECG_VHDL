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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity accumulator is
    generic(
        N       : integer := 24;
        n_out   : integer := 24
    );
    port(
        clk                           : in std_logic;
        initSum, loadSum, loadOutput  : in std_logic;
        v_value, h_coef               : in std_logic_vector(N-1 downto 0);
        sumSelect                     : in std_logic;

        accOutput                     : out std_logic_vector(n_out-1 downto 0)

    );




end accumulator;



architecture Behavioral of accumulator is

    --type v_fir_first is ARRAY(0 to 128) of std_logic_vector(N-1 downto 0);
    --type v_fir_second is ARRAY(0 to 10) of std_logic_vector(N-1 downto 0);
    --type v_iir_no_recursive is ARRAY(0 to 2) of std_logic_vector(N-1 downto 0);
    --type v_iir_recursive is ARRAY(0 to 2) of std_logic_vector(N-1 downto 0);
    signal buff, w_mult   : signed(n_out-1 downto 0);

begin

  w_mult <= (signed(v_value) * signed(h_coef));

  mux_sum : process(clk) is
    begin
    if (initSum = '1') then
        buff <= (others=>'0');
    elsif (RISING_EDGE(clk) and loadSum = '1') then
        if(sumSelect = '0') then
          buff <= buff + w_mult;
        else
          buff <= buff - w_mult;
        end if;
    end if;
    end process mux_sum;

    accOutput <= std_logic_vector(buff) when (RISING_EDGE(clk) and loadOutput = '1');

end Behavioral;
