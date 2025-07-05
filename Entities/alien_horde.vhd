-- alien_horde.vhd
-- This is the top-level entity that instantiates the controller
-- and generates all the alien entities.
-- I have removed the 'aliens_pos_x' and 'aliens_pos_y' ports to
-- resolve the fitter error. The position signals are now internal.

library IEEE;
use IEEE.std_logic_1164.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity alien_horde is
	port(
		clk			: in	std_logic;
		vid_clk		: in	std_logic; -- VGA pixel clock (e.g., 25.175 MHz for 640x480)
		rst			: in	std_logic;
		
		-- Game status output
		game_over	: out	std_logic;
		
		-- VGA outputs
		o_h_sync    : out std_logic;
		o_v_sync    : out std_logic;
		o_red_out   : out std_logic_vector(3 downto 0);
		o_green_out : out std_logic_vector(3 downto 0);
		o_blue_out  : out std_logic_vector(3 downto 0)
	);
end entity alien_horde;

architecture structure of alien_horde is

	-- Component declarations
	component alien_controller is
		port(
			clk			: in	std_logic;
			rst			: in	std_logic;
			down_done_i	: in	std_logic_vector(QT_ALIENS - 1 downto 0);
			left_done_i	: in	std_logic_vector(QT_ALIENS - 1 downto 0);
			right_done_i: in	std_logic_vector(QT_ALIENS - 1 downto 0);
			turn_i		: in	std_logic;
			game_over_i	: in	std_logic;
			down_o		: out	std_logic;
			left_o		: out	std_logic;
			right_o		: out	std_logic;
			game_over_o	: out	std_logic
		);
	end component;
	
	component alien is
		generic(
			init_pos_x	: integer	:=	RES_WIDTH / 2;
			init_pos_y	: integer	:= 0
		);
		port(
			clk			: in	std_logic;
			rst			: in	std_logic;
			down_i		: in	std_logic;
			left_i		: in	std_logic;
			right_i		: in	std_logic;
			pos_x_o		: out	integer range 0 to RES_WIDTH;
			pos_y_o		: out	integer range 0 to RES_HEIGHT;
			down_done_o	: out	std_logic;
			left_done_o	: out	std_logic;
			right_done_o: out	std_logic;
			turn_o		: out	std_logic;
			game_over_o	: out 	std_logic
		);
	end component;
	
	component alien_draw is
		port(
			alien_pos_x_i	: in	integer;
			alien_pos_y_i	: in	integer;
			vga_driver_x_i	: in	std_logic_vector(9 downto 0);
			vga_driver_y_i	: in	std_logic_vector(9 downto 0);
			draw_o	: out	std_logic
		);
	end component;

	component VGA_drvr is
		port(
			i_vid_clk: 		in 	std_logic;
			i_rstb: 			in 	std_logic;
			o_h_sync:		out 	std_logic;
			o_v_sync:		out 	std_logic;
			o_pixel_x: 		out 	std_logic_vector (9 downto 0);
			o_pixel_y: 		out 	std_logic_vector (9 downto 0);
			i_red_in:     	in 	std_logic_vector(3 downto 0);
			i_green_in:		in		std_logic_vector(3 downto 0);
			i_blue_in:		in		std_logic_vector(3 downto 0);
			o_red_out:		out 	std_logic_vector(3 downto 0);
			o_green_out:	out	std_logic_vector(3 downto 0);
			o_blue_out:		out	std_logic_vector(3 downto 0)
	  );
	end component;

	-- Signals to connect controller and aliens
	signal ctrl_down_cmd		: std_logic;
	signal ctrl_left_cmd		: std_logic;
	signal ctrl_right_cmd		: std_logic;
	signal ctrl_game_over_cmd	: std_logic;
	
	-- Feedback signals from aliens to controller
	signal aliens_down_done	: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_left_done	: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_right_done: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_turn		: std_logic_vector(QT_ALIENS - 1 downto 0);
	signal aliens_game_over	: std_logic_vector(QT_ALIENS - 1 downto 0);
	
	-- Combined feedback signals
	signal combined_turn_sig		: std_logic;
	signal combined_game_over_sig	: std_logic;
	
	-- Internal signals to hold alien positions for debugging/observation
	-- inside the FPGA (e.g., with SignalTap). They are not connected to pins.
	signal aliens_pos_x_s: integer_vector(QT_ALIENS - 1 downto 0);
	signal aliens_pos_y_s: integer_vector(QT_ALIENS - 1 downto 0);

	-- Signals for VGA driver and drawing logic
    signal vga_pixel_x_s    : std_logic_vector(9 downto 0);
    signal vga_pixel_y_s    : std_logic_vector(9 downto 0);
    signal aliens_draw_s    : std_logic_vector(QT_ALIENS - 1 downto 0);
    signal combined_draw_s  : std_logic;
	signal vga_rst_n		: std_logic;

begin

	-- Instantiate the main controller
	controller_inst : alien_controller
		port map(
			clk				=> clk,
			rst				=> rst,
			down_done_i		=> aliens_down_done,
			left_done_i		=> aliens_left_done,
			right_done_i	=> aliens_right_done,
			turn_i			=> combined_turn_sig,
			game_over_i		=> combined_game_over_sig,
			down_o			=> ctrl_down_cmd,
			left_o			=> ctrl_left_cmd,
			right_o			=> ctrl_right_cmd,
			game_over_o		=> ctrl_game_over_cmd
		);
		
	-- Instantiate the VGA driver
	vga_rst_n <= not rst; -- VGA driver uses active-low reset
	vga_driver_inst : VGA_drvr
        port map(
            i_vid_clk   => vid_clk,
            i_rstb      => vga_rst_n,
            o_h_sync    => o_h_sync,
            o_v_sync    => o_v_sync,
            o_pixel_x   => vga_pixel_x_s,
            o_pixel_y   => vga_pixel_y_s,
            i_red_in    => (others => '0'),
            i_green_in  => (others => '0'),
            i_blue_in   => (others => combined_draw_s), -- Combined draw signal drives blue
            o_red_out   => o_red_out,
            o_green_out => o_green_out,
            o_blue_out  => o_blue_out
        );

	-- Combine all 'turn' signals from aliens into one using an OR reduction.
	-- If any alien needs to turn, the controller is notified.
	combined_turn_sig <= '0' when aliens_turn = (aliens_turn'range => '0') else '1';
	
	-- Combine all 'game_over' signals from aliens into one.
	combined_game_over_sig <= '0' when aliens_game_over = (aliens_game_over'range => '0') else '1';
	
	-- Set top-level game_over output
	game_over <= ctrl_game_over_cmd;

	-- Generate all alien instances in a grid
	ALIEN_GEN : for i in 0 to QT_ALIENS - 1 generate
		-- Calculate initial position for each alien based on its index 'i'
		constant line_index   : integer := i / QT_ALIENS_PER_LINE;
		constant column_index : integer := i mod QT_ALIENS_PER_LINE;
		
		constant init_x : integer := (RES_WIDTH - (QT_ALIENS_PER_LINE * ALIEN_WIDTH) - ((QT_ALIENS_PER_LINE - 1) * ALIEN_SPACING_X)) / 2 
									+ column_index * (ALIEN_WIDTH + ALIEN_SPACING_X);
									
		constant init_y : integer := START_Y_OFFSET + line_index * (ALIEN_HEIGHT + ALIEN_SPACING_Y);
		
	begin
		-- Instantiate one alien
		alien_inst : alien
			generic map(
				init_pos_x	=> init_x,
				init_pos_y	=> init_y
			)
			port map(
				clk				=> clk,
				rst				=> rst,
				down_i			=> ctrl_down_cmd,
				left_i			=> ctrl_left_cmd,
				right_i			=> ctrl_right_cmd,
				pos_x_o			=> aliens_pos_x_s(i), -- Mapped to internal signal
				pos_y_o			=> aliens_pos_y_s(i), -- Mapped to internal signal
				down_done_o		=> aliens_down_done(i),
				left_done_o		=> aliens_left_done(i),
				right_done_o	=> aliens_right_done(i),
				turn_o			=> aliens_turn(i),
				game_over_o		=> aliens_game_over(i)
			);
			
			-- Instantiate the drawing logic for this alien
        alien_draw_inst : alien_draw
            port map(
                alien_pos_x_i   => aliens_pos_x_s(i),
                alien_pos_y_i   => aliens_pos_y_s(i),
                vga_driver_x_i  => vga_pixel_x_s,
                vga_driver_y_i  => vga_pixel_y_s,
                draw_o          => aliens_draw_s(i)
            );
			
	end generate ALIEN_GEN;

end architecture structure;
