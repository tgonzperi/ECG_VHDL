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
		CONSTANT selector_width : INTEGER := 2;

		N : INTEGER := 24;
		n_out : INTEGER := 48;
		address_width : INTEGER := 7;
		buffer_fir_width : INTEGER := 128;
		buffer_iir_width : INTEGER := 3;
		buffer_fir2_width : INTEGER := 109
	);
	PORT (
		clk : IN std_logic;
		incrAddress, initAddress : IN std_logic;
		inputSample : IN std_logic_vector(N - 1 DOWNTO 0);
		loadShift : IN std_logic;
		selector : IN std_logic_vector(2 - 1 DOWNTO 0);
		accOutput : IN std_logic_vector(n_out - 1 DOWNTO 0);

		processingDone : OUT std_logic;
		address_output : OUT std_logic_vector(address_width - 1 DOWNTO 0);
		v_value, h_coef : OUT std_logic_vector(N - 1 DOWNTO 0) := (others => '0')
	);
END buffers;

ARCHITECTURE Behavioral OF buffers IS

	TYPE t_buffer IS ARRAY (INTEGER RANGE <>) OF std_logic_vector(N - 1 DOWNTO 0);

	SIGNAL buffer_fir : t_buffer(buffer_fir_width DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir_r : t_buffer(buffer_iir_width DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir : t_buffer(buffer_iir_width DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_fir2 : t_buffer(buffer_fir2_width DOWNTO 0) := (others => (others => '0'));

	SIGNAL buffer_fir_coef : t_buffer(buffer_fir_width DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir_r_coef : t_buffer(buffer_iir_width DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_iir_coef : t_buffer(buffer_iir_width DOWNTO 0) := (others => (others => '0'));
	SIGNAL buffer_fir2_coef : t_buffer(buffer_fir2_width DOWNTO 0) := (others => (others => '0'));

	SIGNAL s_address : unsigned(address_width - 1 DOWNTO 0);

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
				s_address <= (OTHERS => '0');
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
						buffer_iir_r(buffer_iir_r'HIGH downto buffer_iir_r'LOW + 1) <= buffer_iir_r(buffer_iir_r'HIGH - 1 downto buffer_iir_r'LOW);
						buffer_iir_r(0) <= accOutput(N - 1 downto 0);
            ELSIF (unsigned(selector) = 1) THEN
						buffer_iir(buffer_iir'HIGH downto buffer_iir'LOW + 1) <= buffer_iir(buffer_iir'HIGH - 1 downto buffer_iir'LOW);
						buffer_iir(0) <= accOutput(N - 1 downto 0);
            ELSIF (unsigned(selector) = 3) THEN
						buffer_fir2(buffer_fir2'HIGH downto buffer_fir2'LOW + 1) <= buffer_fir2(buffer_fir2'HIGH - 1 downto buffer_fir2'LOW);
						buffer_fir2(0) <= accOutput(N - 1 downto 0);
            END IF;
        END IF;
	END PROCESS shifter;

	hh : for i in 0 to (buffer_fir_width - 1) generate
	 	buffer_fir_coef(i)(1) <= '1';
	end generate;


	-- buffer_selector : PROCESS(selector, s_address)
	-- BEGIN
	-- 	-- processingDone <= '0';
	-- 	IF (unsigned(selector) = 0) THEN
	-- 		v_value <= buffer_fir(to_integer(s_address));
	-- 		h_coef <= buffer_fir_coef(to_integer(s_address));
	-- 	    -- IF (s_address = (buffer_fir_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	ELSIF (unsigned(selector) = 1) THEN
	-- 		v_value <= buffer_iir_r(to_integer(s_address));
	-- 		h_coef <= buffer_iir_r_coef(to_integer(s_address));
	-- 	    -- IF (s_address = (buffer_iir_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	ELSIF (unsigned(selector) = 2) THEN
	-- 		v_value <= buffer_iir(to_integer(s_address));
	-- 		h_coef <= buffer_iir_coef(to_integer(s_address));
	-- 	    -- IF (s_address = (buffer_iir_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	ELSIF (unsigned(selector) = 3) THEN
	-- 		v_value <= buffer_fir2(to_integer(s_address));
	-- 		h_coef <= buffer_fir2_coef(to_integer(s_address));
	-- 	    -- IF (s_address = (buffer_fir2_width - 1)) THEN
  --       --         processingDone <= '1';
  --       --     END IF;
	-- 	END IF;
	-- END PROCESS buffer_selector;

	address_output <= std_logic_vector(s_address);
	processingDone <= '1' when 	((unsigned(selector) = 0) AND (s_address = (buffer_fir_width - 1))) OR
															((unsigned(selector) = 1) AND (s_address = (buffer_iir_width - 1))) OR
															((unsigned(selector) = 2) AND (s_address = (buffer_iir_width - 1))) OR
															((unsigned(selector) = 3) AND (s_address = (buffer_fir2_width - 1))) else
										'0';

	with selector select v_value <=
		buffer_fir(to_integer(s_address)) 	when "00",
		buffer_iir_r(to_integer(s_address))	when "01",
		buffer_iir(to_integer(s_address))		when "10",
		buffer_fir2(to_integer(s_address))	when "11",
		(others => '0')											when others;

		with selector select h_coef <=
			buffer_fir_coef(to_integer(s_address)) 		when "00",
			buffer_iir_r_coef(to_integer(s_address))	when "01",
			buffer_iir_coef(to_integer(s_address))		when "10",
			buffer_fir2_coef(to_integer(s_address))		when "11",
			(others => '0')														when others;

END Behavioral;
