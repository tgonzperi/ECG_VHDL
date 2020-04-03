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
use ieee.math_real.all;
use std.textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY buffers IS

	GENERIC (
		CONSTANT selector_width : INTEGER := 2;

		N : INTEGER := 24;
		n_out : INTEGER := 48;
		address_width : INTEGER := 7;
		buffer_fir_width : INTEGER := 129;
		buffer_iir_width : INTEGER := 3;
		buffer_fir2_width : INTEGER := 11
	);
	PORT (
		clk : IN std_logic;
		incrAddress, initAddress : IN std_logic;
		inputSample : IN std_logic_vector(N - 1 DOWNTO 0);
		loadShift : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);

		accOutput : IN std_logic_vector(n_out - 1 DOWNTO 0);

		processingDone : OUT std_logic;
		v_value, h_coef : OUT std_logic_vector(N - 1 DOWNTO 0) := (others => '0')
	);
END buffers;

ARCHITECTURE Behavioral OF buffers IS

	TYPE t_buffer IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(N - 1 DOWNTO 0);

	SIGNAL buffer_fir : t_buffer(buffer_fir_width - 1 DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir_r : t_buffer(buffer_iir_width - 1 - 1  DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir : t_buffer(buffer_iir_width - 1 DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_fir2 : t_buffer(buffer_fir2_width - 1 DOWNTO 0) := (others => (others => '0'));

	SIGNAL buffer_fir_coef : t_buffer(buffer_fir_width - 1 DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir_r_coef : t_buffer(buffer_iir_width - 1 - 1 DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir_coef : t_buffer(buffer_iir_width - 1 DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_fir2_coef : t_buffer(buffer_fir2_width - 1 DOWNTO 0) := (others => (others => '0'));

	SIGNAL s_address : integer := 0;

	signal accOutputReal : real;

	signal coefAux : std_logic_vector(23 downto 0);

    FUNCTION shiftBuffer(
        buff : IN t_buffer;
        inputSampleIn : IN std_logic_vector(N - 1 DOWNTO 0))
				return t_buffer IS
        VARIABLE v_buffer : t_buffer(buff'LENGTH-1 DOWNTO 0);
    BEGIN
        FOR i IN 0 TO v_buffer'LENGTH-2 LOOP
            v_buffer(i+1) := v_buffer(i);
        END LOOP;
        v_buffer(0) := inputSampleIn;
        return v_buffer;
    END FUNCTION;



BEGIN


	address_generator : PROCESS (clk) IS
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (initAddress = '1') THEN
				s_address <= 0;
			ELSIF (incrAddress = '1') THEN
				s_address <= s_address + 1;
			END IF;
		END IF;

	END PROCESS address_generator;

    shifter: PROCESS(clk) IS
    BEGIN
        IF (RISING_EDGE(clk) AND loadShift = '1') THEN
            IF (unsigned(selector) = 0) THEN
              --buffer_fir <=  shiftBuffer(buffer_fir, inputSample);
							buffer_fir(buffer_fir'HIGH downto buffer_fir'LOW + 1) <= buffer_fir(buffer_fir'HIGH - 1 downto buffer_fir'LOW);
							buffer_fir(0) <= inputSample;
            ELSIF (unsigned(selector) = 2) THEN

            ELSIF (unsigned(selector) = 1) THEN
						buffer_iir(buffer_iir'HIGH downto buffer_iir'LOW + 1) <= buffer_iir(buffer_iir'HIGH - 1 downto buffer_iir'LOW);
						buffer_iir(0) <= accOutput;
            ELSIF (unsigned(selector) = 3) THEN
						buffer_fir2(buffer_fir2'HIGH downto buffer_fir2'LOW + 1) <= buffer_fir2(buffer_fir2'HIGH - 1 downto buffer_fir2'LOW);
						buffer_fir2(0) <= accOutput;
						buffer_iir_r(buffer_iir_r'HIGH downto buffer_iir_r'LOW + 1) <= buffer_iir_r(buffer_iir_r'HIGH - 1 downto buffer_iir_r'LOW);
						buffer_iir_r(0) <= accOutput;
					 report "y_minus_BL = " & real'image(accOutputReal);
            END IF;
        END IF;
	END PROCESS shifter;

	-- hh : for i in 0 to (buffer_fir_width - 1) generate
	--  	buffer_fir_coef(i)(1) <= '1';
	-- end generate;

	p_read : process(clk)
	--------------------------------------------------------------------------------------------------
	constant NUM_COL                : integer := 4;   -- number of column of file

	type t_integer_array		   is array(integer range <> )  of integer;
	file test_vector                : text open read_mode is "buffers.txt";
	variable row                    : line;
	variable v_data_read            : real;
	variable v_data_row_counter     : integer := 0;


	begin
	if(rising_edge(clk)) then



			-- read from input file in "row" variable
				if(not endfile(test_vector)) then
					v_data_row_counter := v_data_row_counter + 1;
					readline(test_vector,row);
					-- read integer number from "row" variable in integer array
						read(row,v_data_read);
						if(v_data_row_counter<=129) THEN
							buffer_fir_coef(v_data_row_counter-1) <= std_logic_vector(to_signed(integer(round((v_data_read)*real(2**22))),24));
						elsif v_data_row_counter <= 131 then
							buffer_iir_r_coef(v_data_row_counter-130) <= std_logic_vector(to_signed(integer(round((v_data_read)*real(2**22))),24));
						elsif v_data_row_counter <= 134 then
							buffer_iir_coef(v_data_row_counter-132) <= std_logic_vector(to_signed(integer(round((v_data_read)*real(2**22))),24));
						else
							buffer_fir2_coef(v_data_row_counter-135) <= std_logic_vector(to_signed(integer(round((v_data_read)*real(2**22))),24));
						end if;
				end if;


	 end if;
	end process p_read;

	-- buffer_selector : PROCESS(selector, s_address)
	-- BEGIN
	-- 	-- processingDone <= '0';
	-- 	IF (unsigned(selector) = 0) THEN
	-- 		report "unexpected value. selector0 = " & integer'image(s_address);
	-- 		v_value <= buffer_fir((s_address));
	-- 		h_coef <= buffer_fir_coef((s_address));
	-- 	    -- IF (s_address = (buffer_fir_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	ELSIF (unsigned(selector) = 1) THEN
	-- 		report "unexpected value. selector1 = " & integer'image(s_address);
	-- 		v_value <= buffer_iir_r((s_address));
	-- 		h_coef <= buffer_iir_r_coef((s_address));
	-- 	    -- IF (s_address = (buffer_iir_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	ELSIF (unsigned(selector) = 2) THEN
	-- 		v_value <= buffer_iir((s_address));
	-- 		h_coef <= buffer_iir_coef((s_address));
	-- 	    -- IF (s_address = (buffer_iir_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	ELSIF (unsigned(selector) = 3) THEN
	-- 		v_value <= buffer_fir2((s_address));
	-- 		h_coef <= buffer_fir2_coef((s_address));
	-- 	    -- IF (s_address = (buffer_fir2_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	END IF;
	-- END PROCESS buffer_selector;

	v_value <= 	buffer_fir((s_address)) 	when (unsigned(selector) = 0) else
							buffer_iir_r((s_address)) when (unsigned(selector) = 1) else
							buffer_iir((s_address))		when (unsigned(selector) = 2) else
							buffer_fir2((s_address))	when (unsigned(selector) = 3) else
							(others => 'Z');

	h_coef <=
							buffer_fir_coef((s_address)) 	when (unsigned(selector) = 0) else
							buffer_iir_r_coef((s_address)) when (unsigned(selector) = 1) else
							buffer_iir_coef((s_address))		when (unsigned(selector) = 2) else
							buffer_fir2_coef((s_address))	when (unsigned(selector) = 3) else
							(others => 'Z');

	processingDone <= '1' when 	((selector = "00") AND (s_address = (buffer_fir_width - 1))) OR
															((selector = "01") AND (s_address = (buffer_iir_width - 1 - 1))) OR
															((selector = "10") AND (s_address = (buffer_iir_width - 1))) OR
															((selector = "11") AND (s_address = (buffer_fir2_width - 1))) else
										'0';


	accOutputReal <= real(to_integer(signed(accOutput)))/real(2**15);
END Behavioral;
