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

entity FIR_OP is
    generic(
        N       : integer := 24;
        n_out   : integer := 24
    );
    port(
        clk, rst                                                            : in std_logic;
        valid, processingDone                                               : out std_logic;
        loadShift, initAddress, incAddress, initSum, loadSum, loadOutput    : in std_logic;
        v_value, h_coef                                                              : in std_logic_vector(N-1 downto 0)
    );
    

    

end FIR_OP;



architecture Behavioral of FIR_OP is

    --type v_fir_first is ARRAY(0 to 128) of std_logic_vector(N-1 downto 0);
    --type v_fir_second is ARRAY(0 to 10) of std_logic_vector(N-1 downto 0);
    --type v_iir_no_recursive is ARRAY(0 to 2) of std_logic_vector(N-1 downto 0);
    --type v_iir_recursive is ARRAY(0 to 2) of std_logic_vector(N-1 downto 0);
    signal buff : signed(n_out-1 downto 0);
    
begin

  mux_sum : process(clk) is
    begin
    if (initSum = '1') then
        buff <= (others=>'0');
    elsif (loadSum = '1') then
        buff <= (signed(v_value) * signed(h_coef)) + buff;
    end if;  
    
    end process mux_sum;

end Behavioral;
