library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity space_invaders is
	port(
		clk	: in  std_logic;
		rst	: in  std_logic;
		-- push button 1 input
		-- push button 2 input
		-- sw reset input
	);
end entity;

architecture behavior of space_invaders is

	signal clk_s	: std_logic;
	signal rst_s	: std_logic;
	
	component VGA_drvr is
		port(
			-- clock and reset - vid_clk is the appropriate video clock
			-- vid_clk would be 25MHz for a 640 x 480 display
			i_vid_clk: 		in 	std_logic;
			i_rstb: 			in 	std_logic;
			-- standard video sync signals
			o_h_sync:		out 	std_logic;
			o_v_sync:		out 	std_logic;
			--  X and Y values for current pixel location being written to the screen
			--  Can be used for reference in upper levels of design
			o_pixel_x: 		out 	std_logic_vector (H_counter_size -1 downto 0);
			o_pixel_y: 		out 	std_logic_vector (V_counter_size - 1 downto 0);
			-- signal to indicate display is actively being written
			-- use this to set RGB values to 0 when not on an active part of the screen
			-- ** not used if using the RGB in/out synchronous signals
			o_vid_display:	out 	std_logic;
			-- convenience signals
			-- syncronize rgb outputs to vid_clk
			i_red_in:     	in 	std_logic_vector((Color_bits - 1) downto 0);
			i_green_in:		in		std_logic_vector((Color_bits - 1) downto 0);
			i_blue_in:		in		std_logic_vector((Color_bits - 1) downto 0);
			o_red_out:		out 	std_logic_vector((Color_bits - 1) downto 0);
			o_green_out:	out	std_logic_vector((Color_bits - 1) downto 0);
			o_blue_out:		out	std_logic_vector((Color_bits - 1) downto 0)
		);
	end component;

	component alien_horde is
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
	end component;
	
	component player is
		port(
			clk                 : in  std_logic;
			reset               : in  std_logic;
			enable              : in  std_logic;
			move_left           : in  std_logic;
			move_right          : in  std_logic;
			h_cnt               : in  integer;     -- h_cnt: current horizontal pixel index from VGA driver (0 = left);
			v_cnt               : in  integer;     -- v_cnt: current vertical pixel index (0 = top)
			pixel_on            : out std_logic;
			left_limit_reached  : out std_logic;
			right_limit_reached : out std_logic
		 );
	end component;

begin

	clk_s <= clk;
	rst_s <= rst;

	VGA_drvr_inst	:	VGA_drvr
	port map(
		i_vid_clk	=>	clk_s;
		i_rstb		=>	rst_s;
	);
	
	alien_horde_inst	:	alien_horde
	port map(
		clk	=>	clk_s;
		rst	=>	rst_s;
	);
	
	player_inst	:	player
	port map(
		clk	=>	clk_s;
		reset	=>	rst_s;
	);

	process (clk, rst)
		if rising_edge(clk) then
			
		end if;
	end process;
end architecture;