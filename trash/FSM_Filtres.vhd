library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_Filtres is

  port(
    clk, rst                                                            : in std_logic;
    loadOutput                                                          : in std_logic;
    filtres_done                                                        : out std_logic
    );
end FSM_Filtres;

architecture arch_FSM_Filtres of FSM_Filtres is

  type FSM_state is (FIR1, IIR_R, IIR, FIR2);

  signal current_state, next_state : FSM_state := FIR1;
  signal aux_selADDSUB : std_logic_vector(1 downto 0);


begin
  curr_state : process(clk,rst) is
    begin
      if (rst = '1') then
        current_state <= FIR1;
      elsif(RISING_EDGE(clk)) then
        current_state <= next_state;
      end if;
    end process curr_state;

  nxt_state : process(current_state, loadOutput) is
    begin
        filtres_done <= '0';

        case current_state is
            when FIR1 =>
              if loadOutput = '1' then
                  next_state <= IIR_R;
              else
                 next_state <= FIR1;
              end if;

            when IIR_R =>
              if loadOutput = '1' then
                  next_state <= IIR;
              else
                 next_state <= IIR_R;
              end if;

            when IIR =>
              if loadOutput = '1' then
                  next_state <= FIR2;
              else
                 next_state <= IIR;
              end if;


            when FIR2 =>
              filtres_done <= '1';
              if loadOutput = '1' then
                  next_state <= FIR1;
              else
                 next_state <= FIR2;
              end if;
        end case;

    end process nxt_state;


end architecture;
