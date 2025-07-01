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
        P_Y      : integer := SCREEN_H - P_HEIGHT - 4;
        P_SPEED  : integer := 2
    );
    port (
        clk                 : in  std_logic;
        reset               : in  std_logic;
        enable              : in  std_logic;
        move_left           : in  std_logic;
        move_right          : in  std_logic;
        h_cnt               : in  integer;
        v_cnt               : in  integer;
        pixel_on            : out std_logic;
        left_limit_reached  : out std_logic;
        right_limit_reached : out std_logic
    );
end entity player;

architecture rtl of player is
    -- Player position
    signal player_x    : integer range 0 to SCREEN_W - P_WIDTH := (SCREEN_W - P_WIDTH) / 2;
    -- Sequencing signals
    signal player_on_s : std_logic;
    signal pixel_on_r  : std_logic;

    -- Sprite ROM: each entry is one row of P_WIDTH bits
    type rom_row_t is array (P_WIDTH - 1 downto 0) of std_logic;
    type sprite_rom_t is array (0 to P_HEIGHT - 1) of rom_row_t;
    constant SPRITE_ROM : sprite_rom_t := (
        -- Example 16x8 ship; '1' = pixel on, '0' = transparent
        0 => "0000000011110000",
        1 => "0000000111111000",
        2 => "0000011111111100",
        3 => "0000111111111110",
        4 => "0001111111111111",
        5 => "0011111111111111",
        6 => "0110011001100110",
        7 => "0000001100000000"
    );

begin
    -- Movement
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

    -- Boundary flags
    left_limit_reached  <= '1' when player_x = 0 else '0';
    right_limit_reached <= '1' when player_x = SCREEN_W - P_WIDTH else '0';

    -- Sprite draw logic: check if current beam position overlaps a '1' in ROM
    -- h_cnt: current horizontal pixel index from VGA driver (0 = left); v_cnt: current vertical pixel index (0 = top)
    process(player_x, h_cnt, v_cnt)
    process(player_x, h_cnt, v_cnt)
        variable row_idx : integer;
        variable col_idx : integer;
    begin
        player_on_s <= '0';
        -- Check vertical range
        if v_cnt >= P_Y and v_cnt < P_Y + P_HEIGHT then
            row_idx := v_cnt - P_Y;
            -- Check horizontal range
            if h_cnt >= player_x and h_cnt < player_x + P_WIDTH then
                col_idx := h_cnt - player_x;
                -- ROM bit = '1' => pixel on
                if SPRITE_ROM(row_idx)(col_idx) = '1' then
                    player_on_s <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Pipeline for timing
    pipeline_proc: process(clk)
    begin
        if rising_edge(clk) then
            pixel_on_r <= player_on_s;
            pixel_on   <= pixel_on_r;
        end if;
    end process;

end architecture rtl;
