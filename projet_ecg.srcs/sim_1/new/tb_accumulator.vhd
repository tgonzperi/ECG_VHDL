
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
	GENERIC (
        CONSTANT selector_width : INTEGER := 2;
        N : INTEGER := 24;
        n_out : INTEGER := 48;
        
        address_width : INTEGER := 7;
        buffer_fir_width : INTEGER := 128;
        buffer_iir_width : INTEGER := 3;
        buffer_fir2_width : INTEGER := 109
    );
END tb_accumulator;

ARCHITECTURE testbench OF tb_accumulator IS

COMPONENT TOP_Op IS

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
		incrAddress, initAddress, loadShift : IN std_logic;
		selector : IN std_logic_vector(selector_width - 1 DOWNTO 0);

		initSum, loadSum, loadOutput : IN std_logic;
		sumSelect : IN std_logic;

		processingDone : OUT std_logic;
		accOutput : OUT std_logic_vector(n_out - 1 DOWNTO 0);
		inputSample : IN std_logic_vector(N - 1 DOWNTO 0)
	);
END COMPONENT;

    SIGNAL clk: std_logic := '0';
	SIGNAL incrAddress, initAddress, loadShift : std_logic;
    SIGNAL selector : std_logic_vector(selector_width - 1 DOWNTO 0) := (others => '0');

    SIGNAL initSum, loadSum, loadOutput : std_logic;
    SIGNAL sumSelect : std_logic;

    SIGNAL processingDone : std_logic;
    SIGNAL accOutput : std_logic_vector(n_out - 1 DOWNTO 0);
    SIGNAL inputSample : std_logic_vector(N - 1 DOWNTO 0);

BEGIN

	uut : TOP_Op
        PORT MAP(
            clk => clk,
            incrAddress => incrAddress,
            initAddress => initAddress,
            selector => selector,
            
            initSum => initSum,
            loadSum => loadSum,
            loadOutput => loadOutput,
            loadShift => loadShift,
            
            sumSelect => sumSelect,

            processingDone => processingDone,
            accOutput => accOutput,
            inputSample => inputSample
        );
   
   incrAddress <= '0';
   selector <= "00";
  
   loadShift <= '0';
   initAddress <= '0';
   incrAddress <= '0';
   initSum <= '0';
   loadSum <= '0';
   loadOutput <= '0';
   sumSelect <= '0';
   inputSample <= std_logic_vector(to_unsigned(1, N));
   
   clk_gen : PROCESS
   BEGIN
       clk <= '1';
       WAIT FOR 14ns/2;
       clk <= '0';
       WAIT FOR 14ns/2;
   END PROCESS clk_gen;
   
--   tb: PROCESS(clk) IS
--    VARIABLE   count : INTEGER := 0;
--   BEGIN
--       IF rising_edge(clk) THEN
--           IF count = 0 THEN
--              initAddress <= '1';
--              initSum <= '1';
--           ELSIF count = 1 THEN
--               initAddress <= '1';
--               initSum <= '1';
--               loadShift <= '1';
--           ELSIF (count > 1 AND processingDone = '0')  THEN
--              incrAddress <= '1';
--              loadSum <= '1';
--           ELSIF (processingDone = '1')  THEN
--                 loadOutput <= '1';
--           END IF;
--          count := count + 1;
--       END IF;
       
--   END PROCESS tb;
   
END testbench;