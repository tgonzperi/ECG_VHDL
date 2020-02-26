library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_But is

  port(
    clk, rst  : in std_logic;
    adr_MSBs  : in std_logic_vector(5 downto 0);
    start     : in std_logic;

    selADDSUB : out std_logic_vector(1 downto 0);
    selW      : out std_logic;
    fin       : out std_logic;
    fulladr   : out std_logic_vector(7 downto 0);
    WE        : out std_logic
    );
end FSM_But;

architecture arch_FSM_But of FSM_But is

  type FSM_state is (Reset, A, B, C, D);

  signal current_state, next_state : FSM_state := Reset;
  signal aux_selADDSUB : std_logic_vector(1 downto 0);


begin
  curr_state : process(clk,rst) is
    begin
      if (rst = '1') then
        current_state <= Reset;
      elsif(RISING_EDGE(clk)) then
        current_state <= next_state;
      end if;
    end process curr_state;

  nxt_state : process(current_state, start) is
    begin

      WE  <= '1';
      fin <= '0';
      aux_selADDSUB <= "00";
      selW <= '0';
      case current_state is
        selADDSUB <= aux_selADDSUB;


        when Reset =>
          if start = '1' then
            next_state <= A;
          else
            next_state <= Reset;
          end if;

          WE  <= '0';
          fin <= '0';
        when A =>
          next_state  <= B;

          aux_selADDSUB   <= "00";
          selW        <= '0';

        when B =>
          next_state  <= C;

          aux_selADDSUB   <= "01";
          selW        <= '1';

        when C =>
          next_state  <= D;

          aux_selADDSUB   <= "10";
          selW        <= '0';

        when D =>
          next_state  <= A;

          aux_selADDSUB   <= "11";
          selW        <= '1';
          fin         <= '1';

        end case;
        selADDSUB <= aux_selADDSUB;
        fulladr <= adr_MSBs & aux_selADDSUB;
    end process nxt_state;


end architecture;
