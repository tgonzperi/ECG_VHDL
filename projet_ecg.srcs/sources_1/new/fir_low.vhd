library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_FIR is

  port(
    clk, rst                                                            : in std_logic;
    valid, processingDone                                               : in std_logic;
    filtres_done                                                        : in std_logic;
    loadShift, initAddress, incAddress, initSum, loadSum, loadOutput    : out std_logic
    );
end FSM_FIR;

architecture arch_FSM_FIR of FSM_FIR is

  type FSM_state is (WAIT_SAMPLE, STORE, PROCESSING_LOOP, OUTPUT, WAIT_END_SAMPLE);

  signal current_state, next_state : FSM_state := WAIT_SAMPLE;
  signal aux_selADDSUB : std_logic_vector(1 downto 0);


begin
  curr_state : process(clk,rst) is
    begin
      if (rst = '1') then
        current_state <= WAIT_SAMPLE;
      elsif(RISING_EDGE(clk)) then
        current_state <= next_state;
      end if;
    end process curr_state;

  nxt_state : process(current_state, valid, processingDone) is
    begin
        loadShift <= '0';
        initAddress <= '0';
        incAddress <= '0';
        initSum <= '0';
        loadSum <= '0';
        loadOutput <= '0';

        case current_state is
            when WAIT_SAMPLE =>
                if valid = '1' then
                    initSum <= '1';
                    initAddress <= '1';
                    next_state <= STORE;
                else
                   next_state <= WAIT_SAMPLE;
                end if;

            when STORE =>
                loadShift  <= '1';
                next_state <= PROCESSING_LOOP;

            when PROCESSING_LOOP =>
                if processingDone = '0' then
                    incAddress <= '1';
                    loadSum <= '1';
                    next_state <= PROCESSING_LOOP;
                else
                    next_state <= OUTPUT;
                end if;

            when OUTPUT =>
                loadOutput <= '1';
                if(filtres_done = '1') then
                  next_state  <= WAIT_END_SAMPLE;
                else
                  next_state  <= STORE;
                end if;

            when WAIT_END_SAMPLE =>
                if valid = '0' then
                    next_state <= WAIT_SAMPLE;
                else
                    next_state <= WAIT_END_SAMPLE;
                end if;
        end case;

    end process nxt_state;


end architecture;
