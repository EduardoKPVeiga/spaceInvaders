library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Enhanced Player module with sprite ROM for Space Invaders replica
entity player is
    generic (
        SCREEN_W : integer := 640;
        SCREEN_H : integer := 480;
        P_WIDTH  : integer := 16;
        P_HEIGHT : integer := 8;
        P_SPEED  : integer := 2
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        enable      : in  std_logic;
        move_left   : in  std_logic;
        move_right  : in  std_logic;
        h_cnt       : in  integer;     -- h_cnt: current horizontal pixel index from VGA driver
        v_cnt       : in  integer;     -- v_cnt: current vertical pixel index
        pixel_on    : out std_logic;
        player_x_o  : out integer range 0 to SCREEN_W -- Output for player's X position
    );
end entity player;

architecture rtl of player is
    -- Constant for player's vertical position, calculated from generics.
    -- This resolves the VHDL error where a generic was defined by other generics.
    constant P_Y : integer := SCREEN_H - P_HEIGHT - 4;

    -- Player position signal
    signal player_x    : integer range 0 to SCREEN_W - P_WIDTH := (SCREEN_W - P_WIDTH) / 2;
    
    -- Internal signals for drawing logic
    signal player_on_s : std_logic;
    signal pixel_on_r  : std_logic;

    -- Sprite ROM: each entry is one row of P_WIDTH bits
    type rom_row_t is array (P_WIDTH - 1 downto 0) of std_logic;
    type sprite_rom_t is array (0 to P_HEIGHT - 1) of rom_row_t;
    constant SPRITE_ROM : sprite_rom_t := (
        -- 16x8 ship sprite; '1' = pixel on, '0' = transparent
        0 => "0000000110000000",
        1 => "0000001111000000",
        2 => "0000011111100000",
        3 => "0001111111110000",
        4 => "0011111111111000",
        5 => "0111111111111100",
        6 => "1111111111111110",
        7 => "1101100110011011"
    );

begin
    -- Player movement logic
    movement_proc: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                player_x <= (SCREEN_W - P_WIDTH) / 2;
            elsif enable = '1' then
                if move_left = '1' and player_x > 0 then
                    player_x <= player_x - P_SPEED;
                elsif move_right = '1' and player_x < SCREEN_W - P_WIDTH then
                    player_x <= player_x + P_SPEED;
                end if;
            end if;
        end if;
    end process;

    -- Continuously output the player's position
    player_x_o <= player_x;

    -- Sprite drawing logic: check if the current VGA coordinates overlap a '1' in the ROM
    draw_proc: process(player_x, h_cnt, v_cnt)
        variable row_idx : integer;
        variable col_idx : integer;
    begin
        player_on_s <= '0';
        -- Check if the beam is within the player's vertical range
        if v_cnt >= P_Y and v_cnt < P_Y + P_HEIGHT then
            row_idx := v_cnt - P_Y;
            -- Check if the beam is within the player's horizontal range
            if h_cnt >= player_x and h_cnt < player_x + P_WIDTH then
                col_idx := h_cnt - player_x;
                -- If the corresponding bit in the ROM is '1', turn the pixel on
                if SPRITE_ROM(row_idx)(col_idx) = '1' then
                    player_on_s <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Pipeline the drawing signal for timing purposes
    pipeline_proc: process(clk)
    begin
        if rising_edge(clk) then
            pixel_on_r <= player_on_s;
            pixel_on   <= pixel_on_r;
        end if;
    end process;

end architecture rtl;
