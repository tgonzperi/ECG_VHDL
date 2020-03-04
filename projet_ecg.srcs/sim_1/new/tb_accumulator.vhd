
---------------------------------------------------------------------------
-- Change Log
-- Version 0.0.1 : Initial version
---------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;
USE IEEE.math_real.ALL;

ENTITY tb_accumulator IS
END tb_accumulator;

ARCHITECTURE testbench OF tb_accumulator IS
    CONSTANT N : INTEGER := 22;
    CONSTANT N_OUT: INTEGER := 15;
    CONSTANT clk_period : TIME := 1 ns;

	SIGNAL clk:    std_logic := '0';
	SIGNAL rst:    std_logic := '0';

BEGIN
	uut : ENTITY work.accumulator
        GENERIC MAP(
            N => N,
            n_out => N_OUT
        )
        PORT MAP(
            clk => clk,
            initSum => initSum,
            loadSum => loadSum,
            loadOutput => loadOutput,
            v_value => v_value,
            h_coef => h_coef,
            sumSelect => sumSelect,
            accOutput => accOutput
        );
        
        clk_gen : PROCESS
        BEGIN
            clk <= '1';
            WAIT FOR clk_period/2;
            clk <= '0';
            WAIT FOR clk_period/2;
        END PROCESS clk_gen;
        
        rst_gen : PROCESS
        BEGIN
            rst <= '1';
            WAIT FOR clk_period * 3.5;
            rst <= '0';
            WAIT;
        END PROCESS rst_gen;
        
        angle_gen : PROCESS (clk, rst)
                        VARIABLE   count : INTEGER := 0;
        
        BEGIN
            IF rst = '1' THEN
               angle <= (others => '0');
            ELSIF rising_edge(clk) AND count < 5 THEN
               angle  <= to_signed(integer(angle_array(count) * 2.0**22/MATH_2_PI), width); 
               count := count + 1;
            END IF;
        
        END PROCESS angle_gen;

END testbench;