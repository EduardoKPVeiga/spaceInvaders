library IEEE;
use IEEE.std_logic_1164.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity alien is
	generic(
		init_pos_x	: integer	:=	RES_WIDTH / 2;
		init_pos_y	: integer	:= 0
	);
	port(
		clk			: in	std_logic;
		rst			: in	std_logic;
		
		-- Position outputs
		pos_x_o		: out	integer range 0 to RES_WIDTH;
		pos_y_o		: out	integer range 0 to RES_HEIGHT;
		
		-- Movement commands from controller
		down_i		: in	std_logic;
		left_i		: in	std_logic;
		right_i		: in	std_logic;
		
		-- Status signals
		game_over_i	: in	std_logic;
		die			: in	std_logic; -- Input to signal that the alien was hit
		is_alive_o	: out	std_logic; -- Output to signal if the alien is alive
		
		-- Feedback to controller
		turn_o		: out	std_logic;
		game_over_o	: out 	std_logic
	);
end alien;

architecture behavior of alien is
	signal pos_x_s		: integer range 0 to RES_WIDTH	:= init_pos_x;
	signal pos_y_s		: integer range 0 to RES_HEIGHT	:= init_pos_y;
	signal is_alive_s	: std_logic := '1';
begin

	process(clk, rst)
	begin
		if (rst = '1') then
				-- Reset alien to initial state
				pos_x_s <= init_pos_x;
				pos_y_s <= init_pos_y;
				is_alive_s <= '1';
				game_over_o <= '0';
				turn_o <= '0';
				
		elsif rising_edge(clk) then
				-- Default outputs to '0' each cycle to prevent latches
				turn_o       <= '0';
				game_over_o  <= '0';

				-- If alien is hit, it dies. This is a final state until reset.
				if (die = '1') then
					is_alive_s <= '0';
				end if;

				-- Alien only moves and acts if it is alive
				if (is_alive_s = '1') then
					if (game_over_i = '1') then
						-- Game is over, freeze in place
					elsif (down_i = '1') then
						if (pos_y_s + ALIEN_HEIGHT >= END_LINE) then -- Alien reached the player's line
							game_over_o	<= '1';
						else
							pos_y_s <= pos_y_s + ALIEN_MOVE_IT;
						end if;
					elsif (left_i = '1') then
						if (pos_x_s <= ALIEN_MOVE_IT) then -- Alien reached the left screen edge
							turn_o <= '1';
						else
							pos_x_s <= pos_x_s - ALIEN_MOVE_IT;
						end if;

					elsif (right_i = '1') then
						if (pos_x_s + ALIEN_WIDTH + ALIEN_MOVE_IT >= RES_WIDTH) then -- Alien reached the right screen edge
							turn_o <= '1';
						else
							pos_x_s <= pos_x_s + ALIEN_MOVE_IT;
						end if;
					end if;
				end if;
		end if;
	end process;

	-- Continuously output the internal state
	pos_x_o <= pos_x_s;
	pos_y_o <= pos_y_s;
	is_alive_o <= is_alive_s;

end architecture;
