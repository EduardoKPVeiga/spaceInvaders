-- File: alien.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity alien is
    generic (
        init_pos_x : integer := RES_WIDTH / 2;
        init_pos_y : integer := 0
    );
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        down_i       : in  std_logic;
        left_i       : in  std_logic;
        right_i      : in  std_logic;
        game_over_i  : in  std_logic;
        die          : in  std_logic;
        pos_x_o      : out integer range 0 to RES_WIDTH;
        pos_y_o      : out integer range 0 to RES_HEIGHT;
        is_alive_o   : out std_logic;
        turn_o       : out std_logic;
        game_over_o  : out std_logic
    );
end entity;

architecture behavior of alien is
    signal pos_x_s    : integer range 0 to RES_WIDTH  := init_pos_x;
    signal pos_y_s    : integer range 0 to RES_HEIGHT := init_pos_y;
    signal is_alive_s : std_logic := '1';
    signal bool_down  : std_logic := '0';
    signal bool_left  : std_logic := '0';
    signal bool_right : std_logic := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            pos_x_s      <= init_pos_x;
            pos_y_s      <= init_pos_y;
            is_alive_s   <= '1';
            bool_down    <= '0';
            bool_left    <= '0';
            bool_right   <= '0';
            turn_o       <= '0';
            game_over_o  <= '0';
        elsif rising_edge(clk) then
            turn_o      <= '0';
            game_over_o <= '0';
            if die = '1' then
                is_alive_s <= '0';
            end if;
            if down_i = '0' then bool_down <= '0'; end if;
            if left_i = '0' then bool_left <= '0'; end if;
            if right_i = '0' then bool_right <= '0'; end if;
            if is_alive_s = '1' and game_over_i = '0' then
                if down_i = '1' and bool_down = '0' then
                    bool_down <= '1';
                    if pos_y_s + ALIEN_HEIGHT >= END_LINE then
                        game_over_o <= '1';
                    else
                        pos_y_s <= pos_y_s + ALIEN_MOVE_IT;
                    end if;
                elsif left_i = '1' and bool_left = '0' then
                    bool_left <= '1';
                    if pos_x_s <= ALIEN_MOVE_IT then
                        turn_o <= '1';
                    else
                        pos_x_s <= pos_x_s - ALIEN_MOVE_IT;
                    end if;
                elsif right_i = '1' and bool_right = '0' then
                    bool_right <= '1';
                    if pos_x_s + ALIEN_WIDTH + ALIEN_MOVE_IT >= RES_WIDTH then
                        turn_o <= '1';
                    else
                        pos_x_s <= pos_x_s + ALIEN_MOVE_IT;
                    end if;
                end if;
            end if;
        end if;
    end process;

    pos_x_o    <= pos_x_s;
    pos_y_o    <= pos_y_s;
    is_alive_o <= is_alive_s;

end architecture;
