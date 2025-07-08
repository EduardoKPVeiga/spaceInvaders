library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

-- This is the top-level entity for the Space Invaders game.
-- It integrates all sub-modules: player, shot, alien horde, and text screens.
entity space_invaders is
	port(
		-- System Inputs
		clk_50mhz   : in  std_logic;
		rst         : in  std_logic;

		-- Player Controls
		btn_left    : in  std_logic;
		btn_right   : in  std_logic;

		-- VGA Outputs
		vga_h_sync  : out std_logic;
		vga_v_sync  : out std_logic;
		vga_r       : out std_logic_vector(3 downto 0);
		vga_g       : out std_logic_vector(3 downto 0);
		vga_b       : out std_logic_vector(3 downto 0)
	);
end entity space_invaders;

architecture structure of space_invaders is

    -- Internal Signals
	signal vid_clk          : std_logic := clk_50mhz;
	signal game_clk         : std_logic := clk_50mhz;
	signal vga_rst_n        : std_logic;
	signal game_enable      : std_logic;
	signal game_over_s      : std_logic;
	signal you_won_s        : std_logic; -- Signal for the win condition
	signal vga_pixel_x_s    : std_logic_vector(9 downto 0);
	signal vga_pixel_y_s    : std_logic_vector(9 downto 0);
	signal vga_pixel_x_int  : integer range 0 to RES_WIDTH;
	signal vga_pixel_y_int  : integer range 0 to RES_HEIGHT;
	signal player_pixel_on_s: std_logic;
	signal player_x_s       : integer range 0 to RES_WIDTH;
	signal shot_pixel_on_s  : std_logic;
	signal shot_x_s         : integer;
	signal shot_y_s         : integer;
	signal shot_active_s    : std_logic;
	signal aliens_h_sync_s, aliens_v_sync_s : std_logic;
	signal aliens_r_s, aliens_g_s, aliens_b_s : std_logic_vector(3 downto 0);
	signal text_r_s, text_g_s, text_b_s       : std_logic_vector(3 downto 0);
	signal combined_r_s, combined_g_s, combined_b_s : std_logic_vector(3 downto 0);

	-- Component Declarations
	component VGA_drvr is
		port(
			i_vid_clk: in std_logic;
			i_rstb: in std_logic;
			o_h_sync: out std_logic;
			o_v_sync: out std_logic;
			o_pixel_x: out std_logic_vector(9 downto 0);
			o_pixel_y: out std_logic_vector(9 downto 0);
			i_red_in: in std_logic_vector(3 downto 0);
			i_green_in: in std_logic_vector(3 downto 0);
			i_blue_in: in std_logic_vector(3 downto 0);
			o_red_out: out std_logic_vector(3 downto 0);
			o_green_out: out std_logic_vector(3 downto 0);
			o_blue_out: out std_logic_vector(3 downto 0)
		);
	end component;
		
	component player is
		generic(
			SCREEN_W: integer;
			SCREEN_H: integer;
			P_WIDTH: integer;
			P_HEIGHT:integer;
			P_SPEED: integer
		);
		port(
			clk: in std_logic;
			reset: in std_logic;
			enable: in std_logic;
			move_left: in std_logic;
			move_right: in std_logic;
			h_cnt: in integer;
			v_cnt: in integer;
			pixel_on: out std_logic;
			player_x_o: out integer range 0 to SCREEN_W
		);
	end component;
	
	component shot is
		port( clk: in std_logic; rst: in std_logic; enable: in std_logic; player_x_i: in integer; h_cnt: in integer; v_cnt: in integer; pixel_on_o: out std_logic; shot_x_o: out integer; shot_y_o: out integer; active_o: out std_logic ); end component;
    
	-- Updated alien_horde component to include the win condition output
	component alien_horde is
		port(
			clk: in std_logic;
			vid_clk: in std_logic;
			rst: in std_logic;
			shot_x_i: in integer;
			shot_y_i: in integer;
			shot_active_i: in std_logic;
			game_over: out std_logic;
			all_aliens_dead_o: out std_logic;
			o_h_sync: out std_logic;
			o_v_sync: out std_logic;
			o_red_out: out std_logic_vector(3 downto 0);
			o_green_out: out std_logic_vector(3 downto 0);
			o_blue_out: out std_logic_vector(3 downto 0)
		);
	end component;
    
	-- New screen_text component for displaying end screens
	component screen_text is
		port(
			h_cnt: in integer range 0 to RES_WIDTH;
			v_cnt: in integer range 0 to RES_HEIGHT;
			game_over_i: in std_logic;
			you_won_i: in std_logic;
			red_o: out std_logic_vector(3 downto 0);
			green_o: out std_logic_vector(3 downto 0);
			blue_o: out std_logic_vector(3 downto 0)
		);
	end component;

begin

	vga_rst_n <= not rst;
	-- The game is active only when it's not game over and not won.
	game_enable <= not game_over_s and not you_won_s;

	vga_pixel_x_int <= to_integer(unsigned(vga_pixel_x_s));
	vga_pixel_y_int <= to_integer(unsigned(vga_pixel_y_s));

	-- Instantiations
	vga_driver_inst : VGA_drvr
		port map(
			i_vid_clk=>vid_clk,
			i_rstb=>vga_rst_n,
			o_h_sync=>vga_h_sync,
			o_v_sync=>vga_v_sync,
			o_pixel_x=>vga_pixel_x_s,
			o_pixel_y=>vga_pixel_y_s,
			i_red_in=>combined_r_s,
			i_green_in=>combined_g_s,
			i_blue_in=>combined_b_s,
			o_red_out=>vga_r,
			o_green_out=>vga_g,
			o_blue_out=>vga_b
		);
		
	player_inst : player
		generic map(
			SCREEN_W=>RES_WIDTH,
			SCREEN_H=>RES_HEIGHT,
			P_WIDTH=>16,
			P_HEIGHT=>8,
			P_SPEED=>2
		)
		
		port map(
			clk=>game_clk,
			reset=>rst,
			enable=>game_enable,
			move_left=>btn_left,
			move_right=>btn_right,
			h_cnt=>vga_pixel_x_int,
			v_cnt=>vga_pixel_y_int,
			pixel_on=>player_pixel_on_s,
			player_x_o=>player_x_s
		);
	
	shot_inst : shot
		port map(
			clk=>game_clk,
			rst=>rst,
			enable=>game_enable,
			player_x_i=>player_x_s,
			h_cnt=>vga_pixel_x_int,
			v_cnt=>vga_pixel_y_int,
			pixel_on_o=>shot_pixel_on_s,
			shot_x_o=>shot_x_s,
			shot_y_o=>shot_y_s,
			active_o=>shot_active_s
		);
    
	alien_horde_inst : alien_horde
		port map(
			clk=>game_clk,
			vid_clk=>vid_clk,
			rst=>rst,
			shot_x_i=>shot_x_s,
			shot_y_i=>shot_y_s,
			shot_active_i=>shot_active_s,
			game_over=>game_over_s,
			all_aliens_dead_o=>you_won_s,
			o_h_sync=>aliens_h_sync_s,
			o_v_sync=>aliens_v_sync_s,
			o_red_out=>aliens_r_s,
			o_green_out=>aliens_g_s,
			o_blue_out=>aliens_b_s
		);
    
	screen_text_inst : screen_text
		port map(
			h_cnt=>vga_pixel_x_int,
			v_cnt=>vga_pixel_y_int,
			game_over_i=>game_over_s,
			you_won_i=>you_won_s,
			red_o=>text_r_s,
			green_o=>text_g_s,
			blue_o=>text_b_s
		);

	-- This process multiplexes the video sources. End screens have the highest priority.
	video_mux_proc: process(game_over_s, you_won_s, player_pixel_on_s, shot_pixel_on_s, aliens_b_s, aliens_r_s, aliens_g_s, text_r_s, text_g_s, text_b_s)
	
	begin
		if game_over_s = '1' or you_won_s = '1' then
			-- Show the end screen text
			combined_r_s <= text_r_s;
			combined_g_s <= text_g_s;
			combined_b_s <= text_b_s;
			
		elsif player_pixel_on_s = '1' then
			-- Show the player (Green)
			combined_r_s <= (others => '0');
			combined_g_s <= "1111";
			combined_b_s <= (others => '0');
			
		elsif shot_pixel_on_s = '1' then
			-- Show the shot (Yellow/White)
			combined_r_s <= "1111";
			combined_g_s <= "1111";
			combined_b_s <= (others => '0');
			
		else
			-- Show the aliens (Blue)
			combined_r_s <= aliens_r_s;
			combined_g_s <= aliens_g_s;
			combined_b_s <= aliens_b_s;
		end if;
	end process;

end architecture structure;
