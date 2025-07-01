library IEEE;
use IEEE.std_logic_1164.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

---------------------------------------------------------------------------

-- This entity will be used in conjunction with a alien_controller
-- The entity will receive an action from the controller
-- The entity will send an signal to the controller if the action was executed

---------------------------------------------------------------------------

entity alien is
	generic(
		init_pos_x	: integer	:=	RES_WIDTH / 2;
		init_pos_y	: integer	:= 0
	);
	
	port(
		clk	: in	std_logic;
		rst	: in	std_logic;
		
		pos_x_o		: out	integer range 0 to RES_WIDTH;
		pos_y_o		: out	integer range 0 to RES_HEIGHT;
		down_i		: in	std_logic;
		left_i		: in	std_logic;
		right_i		: in	std_logic;
		game_over_i	: in	std_logic;
		down_o		: out	std_logic;
		left_o		: out	std_logic;
		right_o		: out	std_logic;
		turn_o		: out	std_logic;
		game_over_o	: out std_logic
	);
end alien;

architecture behavior of alien is
	signal pos_x_s	: integer range 0 to RES_WIDTH	:= init_pos_x;
	signal pos_y_s	: integer range 0 to RES_HEIGHT	:= init_pos_y;
begin
	process(clk, rst)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				-- Do the RESET logic
			end if;
		
			if (game_over_i = '1') then
				-- Do the GAME OVER logic
			
			elsif (down_i = '1') then
				if (pos_y_s + ALIEN_MOVE_IT >= END_LINE) then -- Alien reach the spaceship line
					game_over_o	<= '1';
					down_o		<= '0';
					right_o		<= '0';
					left_o		<= '0';
					turn_o		<= '0';
				else
					pos_y_s <= pos_y_s + ALIEN_MOVE_IT;
					down_o <= '1';
				end if;
				
			elsif (left_i = '1') then
				if (pos_x_s - ALIEN_MOVE_IT <= 0) then -- Alien reach the screen limit
					turn_o <= '1';
				else
					pos_x_s <= pos_x_s - ALIEN_MOVE_IT;
				end if;
				left_o <= '1';
			
			elsif (right_i = '1') then
				if (pos_x_s + ALIEN_MOVE_IT >= RES_WIDTH) then -- Alien reach the screen limit
					turn_o <= '1';
				else
					pos_x_s <= pos_x_s + ALIEN_MOVE_IT;
				end if;
				right_o <= '1';
			
			end if;
			
			pos_x_o <= pos_x_s;
			pos_y_o <= pos_y_s;
		end if;
	end process;
end architecture;