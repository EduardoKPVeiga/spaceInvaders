 library IEEE;
use IEEE.std_logic_1164.all;

---------------------------------------------------------------------------

--   #     #
--    #   #
--   #######
--  ## ### ##
-- ###########
-- # ####### #
-- # #     # #
--    ## ##

---------------------------------------------------------------------------

entity alien_draw is
	port(
		clk	: in	std_logic;
		rst	: in	std_logic;
		
		alien_pos_x_i	: in	integer;
		alien_pos_y_i	: in	integer;
		
		vga_driver_x_i	: in	std_logic_vector(9 downto 0);
		vga_driver_y_i	: in	std_logic_vector(9 downto 0);
		
		draw_o	: out	std_logic;
	);
end alien_draw;

architecture behavior of alien_draw is
	signal vga_x	: integer	<= to_integer(unsigned(vga_driver_x));
	signal vga_y	: integer	<= to_integer(unsigned(vga_driver_y));
begin 
	process(clk, rst)
	begin
		if rising_edge(clk) then
			if (vga_y = alien_pos_y) then
				if (vga_x = alien_pos_x + 2) or (vga_x = alien_pos_x + 8) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 1) then
				if (vga_x = alien_pos_x + 3) or (vga_x = alien_pos_x + 7) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 2) then
				if (vga_x > alien_pos_x + 1) and (vga_x < alien_pos_x + 9) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 3) then
				if (vga_x > alien_pos_x) and (vga_x < alien_pos_x + 10) and (vga_x != alien_pos_x + 3) and (vga_x != alien_pos_x + 7) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 4) then
				if (vga_x >= alien_pos_x) and (vga_x <= alien_pos_x + 10) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 5) then
				if (vga_x = alien_pos_x) or ((vga_x > alien_pos_x + 1) and (vga_x < alien_pos_x + 9)) or (vga_x != alien_pos_x + 10) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 6) then
				if (vga_x = alien_pos_x) or (vga_x = alien_pos_x + 2) or (vga_x = alien_pos_x + 8) or (vga_x = alien_pos_x + 10) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			elsif (vga_y = alien_pos_y + 7) then
				if (vga_x = alien_pos_x + 3) or (vga_x = alien_pos_x + 4) or (vga_x = alien_pos_x + 6) or (vga_x = alien_pos_x + 7) then
					draw_o <= '1';
				else
					draw_o <= '0';
				end if;
			end if;
		end if;
	end process;
end architecture;