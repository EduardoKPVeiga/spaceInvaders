library IEEE;
use IEEE.std_logic_1164.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity alien_horde is
	port(
		clk		: in	std_logic;
		rst		: in	std_logic;
		
		-- Inputs from player's shot
		shot_x_i			: in    integer;
		shot_y_i			: in    integer;
		shot_active_i	: in    std_logic;
		
		-- Game status outputs
		game_over			: out	std_logic;
		all_aliens_dead_o	: out   std_logic; -- New output for win condition
		
		-- VGA ports
		vga_pixel_x_i	: in	std_logic_vector(9 downto 0);
		vga_pixel_y_i	: in	std_logic_vector(9 downto 0);
		horde_draw_o			: out	std_logic
	);
end entity alien_horde;

architecture structure of alien_horde is

	-- Component declarations
	component alien_controller is
		port(
			clk	: in std_logic;
			rst	: in std_logic;
			
			turn_i		: in std_logic;
			game_over_i	: in std_logic;
			
			down_o		: out std_logic;
			left_o		: out std_logic;
			right_o		: out std_logic;
			game_over_o	: out std_logic
		);
	end component;
	
	component alien is
		generic(
			init_pos_x	: integer;
			init_pos_y	: integer
		);
		port(
			clk	: in std_logic;
			rst	: in std_logic;
			
			pos_x_o	: out integer range 0 to RES_WIDTH;
			pos_y_o	: out integer range 0 to RES_HEIGHT;
			
			down_i		: in std_logic;
			left_i		: in std_logic;
			right_i		: in std_logic;
			game_over_i	: in std_logic;
			
			die: in std_logic;
			
			is_alive_o	: out std_logic;
			turn_o		: out std_logic;
			game_over_o	: out std_logic
		);
	end component;
	
	component alien_draw is
		port(
			alien_pos_x_i	: in integer;
			alien_pos_y_i	: in integer;
			
			is_alive_i	: in std_logic;
			
			vga_driver_x_i	: in std_logic_vector(9 downto 0);
			vga_driver_y_i	: in std_logic_vector(9 downto 0);
			
			draw_o	: out std_logic
		);
	end component;
	
	component collision_controller is
		port(
			shot_x_i			: in integer;
			shot_y_i			: in integer;
			shot_active_i	: in std_logic;
			
			alien_x_i			: in integer;
			alien_y_i			: in integer;
			alien_is_alive_i	: in std_logic;
			
			collision_o	: out std_logic
		);
	end component;

	-- Internal signals
	signal ctrl_down_cmd			: std_logic;
	signal ctrl_left_cmd			: std_logic;
	signal ctrl_right_cmd		: std_logic;
	signal ctrl_game_over_cmd	: std_logic;
	
	signal aliens_turn			: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_game_over		: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_pos_x_s		: integer_vector(QT_ALIENS - 1 downto 0);
	signal aliens_pos_y_s		: integer_vector(QT_ALIENS - 1 downto 0);
	signal aliens_is_alive_s	: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_collision_s 	: std_logic_vector(QT_ALIENS - 1 downto 0);
	
	signal combined_turn_sig		: std_logic;
	signal combined_game_over_sig	: std_logic;
	
	signal aliens_draw_s    : std_logic_vector(QT_ALIENS - 1 downto 0);
	signal combined_draw_s  : std_logic;

begin

	-- Logic to check if all aliens are dead
	all_aliens_dead_o <= '1' when aliens_is_alive_s = (aliens_is_alive_s'range => '0') else '0';

	-- Instantiations
	controller_inst : alien_controller
		port map(
			clk=>clk,
			rst=>rst,
			turn_i=>combined_turn_sig,
			game_over_i=>combined_game_over_sig,
			down_o=>ctrl_down_cmd,
			left_o=>ctrl_left_cmd,
			right_o=>ctrl_right_cmd,
			game_over_o=>ctrl_game_over_cmd
		);
	
	combined_turn_sig <= '1' when aliens_turn /= (aliens_turn'range => '0') else '0';
	
	combined_game_over_sig <= '1' when aliens_game_over /= (aliens_game_over'range => '0') else '0';
	
	combined_draw_s <= '1' when aliens_draw_s /= (aliens_draw_s'range => '0') else '0';
	horde_draw_o <= combined_draw_s;
	
	game_over <= ctrl_game_over_cmd;

	-- Generate all alien instances
	ALIEN_GEN : for i in 0 to QT_ALIENS - 1 generate
		constant line_index   : integer := i / QT_ALIENS_PER_LINE;
		constant column_index : integer := i mod QT_ALIENS_PER_LINE;
		constant init_x : integer := (RES_WIDTH - (QT_ALIENS_PER_LINE * ALIEN_WIDTH) - ((QT_ALIENS_PER_LINE - 1) * ALIEN_SPACING_X)) / 2 + column_index * (ALIEN_WIDTH + ALIEN_SPACING_X);
		constant init_y : integer := START_Y_OFFSET + line_index * (ALIEN_HEIGHT + ALIEN_SPACING_Y);
	begin
		alien_inst : alien
			generic map(
				init_pos_x => init_x,
				init_pos_y => init_y
			)
			port map(
				clk=>clk,
				rst=>rst,
				down_i=>ctrl_down_cmd,
				left_i=>ctrl_left_cmd,
				right_i=>ctrl_right_cmd,
				game_over_i=>ctrl_game_over_cmd,
				die=>aliens_collision_s(i),
				pos_x_o=>aliens_pos_x_s(i),
				pos_y_o=>aliens_pos_y_s(i),
				is_alive_o=>aliens_is_alive_s(i),
				turn_o=>aliens_turn(i),
				game_over_o=>aliens_game_over(i)
			);
		
		alien_draw_inst : alien_draw
			port map(
				alien_pos_x_i=>aliens_pos_x_s(i),
				alien_pos_y_i=>aliens_pos_y_s(i),
				is_alive_i=>aliens_is_alive_s(i),
				vga_driver_x_i=>vga_pixel_x_i,
				vga_driver_y_i=>vga_pixel_y_i,
				draw_o=>aliens_draw_s(i)
			);
		
		collision_controller_inst : collision_controller
			port map(
				shot_x_i=>shot_x_i,
				shot_y_i=>shot_y_i,
				shot_active_i=>shot_active_i,
				alien_x_i=>aliens_pos_x_s(i),
				alien_y_i=>aliens_pos_y_s(i),
				alien_is_alive_i=>aliens_is_alive_s(i),
				collision_o=>aliens_collision_s(i)
			);
	end generate ALIEN_GEN;

end architecture structure;
