-- File: alien_controller.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity alien_controller is
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    turn_i      : in  std_logic;
    game_over_i : in  std_logic;
    down_o      : out std_logic;
    left_o      : out std_logic;
    right_o     : out std_logic;
    game_over_o : out std_logic
  );
end entity;

architecture behavior of alien_controller is
  signal prev_x_axis_move : std_logic := '0';
  signal down_flag        : std_logic := '1';
  signal left_flag        : std_logic := '0';
  signal right_flag       : std_logic := '0';
  signal game_over_flag   : std_logic := '0';
begin
  down_o      <= down_flag;
  left_o      <= left_flag;
  right_o     <= right_flag;
  game_over_o <= game_over_flag;

  process(clk, rst)
  begin
    if rst = '1' then
      prev_x_axis_move <= '0';
      down_flag        <= '1';
      left_flag        <= '0';
      right_flag       <= '0';
      game_over_flag   <= '0';
    elsif rising_edge(clk) then
      game_over_flag <= '0';
      if game_over_i = '1' then
        game_over_flag <= '1';
        down_flag      <= '0';
        left_flag      <= '0';
        right_flag     <= '0';
      elsif down_flag = '1' then
        down_flag <= '0';
        if prev_x_axis_move = '0' then
          right_flag <= '1';
        else
          left_flag  <= '1';
        end if;
      elsif right_flag = '1' then
        if turn_i = '1' then
          prev_x_axis_move <= '1';
          right_flag       <= '0';
          down_flag        <= '1';
        end if;
      elsif left_flag = '1' then
        if turn_i = '1' then
          prev_x_axis_move <= '0';
          left_flag        <= '0';
          down_flag        <= '1';
        end if;
      end if;
    end if;
  end process;

end architecture;
