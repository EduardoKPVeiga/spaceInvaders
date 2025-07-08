library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity shot is
    generic (
        -- Determines how often a shot is fired.
        -- With a 50MHz clock, 25,000,000 cycles is 0.5 seconds.
        FIRE_RATE_CYCLES : integer := 25_000_000
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        enable      : in  std_logic;      -- To pause the shot when game is over
        player_x_i  : in  integer;        -- To know where to fire from
        h_cnt       : in  integer;        -- VGA horizontal counter
        v_cnt       : in  integer;        -- VGA vertical counter
        pixel_on_o  : out std_logic;
        shot_x_o    : out integer;
        shot_y_o    : out integer;
        active_o    : out std_logic
    );
end entity;

architecture behavior of shot is
    -- Shot properties
    constant SHOT_WIDTH     : integer := 2;
    constant SHOT_HEIGHT    : integer := 5;
    constant SHOT_SPEED     : integer := 4;
    constant PLAYER_Y_POS   : integer := RES_HEIGHT - 16 - 8 - 4; -- Matches player Y position

    -- State machine for the shot
    type shot_state_t is (IDLE, FIRING);
    signal state        : shot_state_t := IDLE;

    -- Internal signals for shot position
    signal shot_x_s     : integer range 0 to RES_WIDTH  := 0;
    signal shot_y_s     : integer range 0 to RES_HEIGHT := 0;

    -- Counter for automatic firing
    signal fire_counter_s : integer range 0 to FIRE_RATE_CYCLES := 0;

begin
    -- Shot logic process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                fire_counter_s <= 0;
            elsif enable = '1' then
                case state is
                    when IDLE =>
                        -- Wait for the fire counter to reach its limit
                        if fire_counter_s >= FIRE_RATE_CYCLES - 1 then
                            state <= FIRING;
                            -- Start the shot centered above the player
                            shot_x_s <= player_x_i + (16 / 2) - (SHOT_WIDTH / 2); -- 16 is player width
                            shot_y_s <= PLAYER_Y_POS - SHOT_HEIGHT;
                            fire_counter_s <= 0;
                        else
                            fire_counter_s <= fire_counter_s + 1;
                        end if;

                    when FIRING =>
                        -- Reset the fire counter while a shot is active
                        fire_counter_s <= 0;
                        -- Move the shot up the screen
                        shot_y_s <= shot_y_s - SHOT_SPEED;
                        -- If shot goes off-screen, return to idle to start the timer again
                        if shot_y_s - SHOT_SPEED < 0 then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Set the active output based on the state
    active_o <= '1' when state = FIRING else '0';
    
    -- Output the shot's current position
    shot_x_o <= shot_x_s;
    shot_y_o <= shot_y_s;

    -- Drawing logic for the shot (a simple vertical rectangle)
    draw_proc: process(h_cnt, v_cnt, shot_x_s, shot_y_s, state)
    begin
        pixel_on_o <= '0';
        if state = FIRING then
            if  (v_cnt >= shot_y_s) and (v_cnt < shot_y_s + SHOT_HEIGHT) and
                (h_cnt >= shot_x_s) and (h_cnt < shot_x_s + SHOT_WIDTH) then
                pixel_on_o <= '1';
            end if;
        end if;
    end process;

end architecture;
