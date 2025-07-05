 library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
		
		draw_o	: out	std_logic
	);
end alien_draw;

architecture behavior of alien_draw is
	-- Internal signals to hold integer versions of the VGA coordinates
	signal vga_x	: integer range 0 to 1023;
	signal vga_y	: integer range 0 to 1023;
begin 
	-- Concurrently convert std_logic_vector inputs to integers
	vga_x <= to_integer(unsigned(vga_driver_x_i));
	vga_y <= to_integer(unsigned(vga_driver_y_i));
	
	process(clk, rst)
	begin
		if rising_edge(clk) then
			-- Default to not drawing
			draw_o <= '0';

			-- Optimization: Check if the current pixel is within the alien's bounding box.
			-- The alien is 11 pixels wide and 8 pixels tall.
			if (vga_y >= alien_pos_y_i) and (vga_y < alien_pos_y_i + 8) and
				(vga_x >= alien_pos_x_i) and (vga_x < alien_pos_x_i + 11) then
			
				-- Alien bitmap drawing logic (based on ASCII art in original file)
				if (vga_y = alien_pos_y_i) then -- Line 0: "  #     #  "
					if (vga_x = alien_pos_x_i + 2) or (vga_x = alien_pos_x_i + 8) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 1) then -- Line 1: "   #   #   "
					if (vga_x = alien_pos_x_i + 3) or (vga_x = alien_pos_x_i + 7) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 2) then -- Line 2: "  #######  "
					if (vga_x >= alien_pos_x_i + 2) and (vga_x <= alien_pos_x_i + 8) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 3) then -- Line 3: " ## ### ## "
					if ((vga_x >= alien_pos_x_i + 1) and (vga_x <= alien_pos_x_i + 9)) and not ((vga_x = alien_pos_x_i + 4) or (vga_x = alien_pos_x_i + 6)) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 4) then -- Line 4: "###########"
					if (vga_x >= alien_pos_x_i) and (vga_x <= alien_pos_x_i + 10) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 5) then -- Line 5: "# ####### #"
					if (vga_x = alien_pos_x_i) or (vga_x = alien_pos_x_i + 10) or ((vga_x >= alien_pos_x_i + 2) and (vga_x <= alien_pos_x_i + 8)) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 6) then -- Line 6: "# #     # #"
					if (vga_x = alien_pos_x_i) or (vga_x = alien_pos_x_i + 10) or (vga_x = alien_pos_x_i + 2) or (vga_x = alien_pos_x_i + 8) then
						draw_o <= '1';
					end if;
				elsif (vga_y = alien_pos_y_i + 7) then -- Line 7: "   ## ##   "
					if (vga_x = alien_pos_x_i + 3) or (vga_x = alien_pos_x_i + 4) or (vga_x = alien_pos_x_i + 6) or (vga_x = alien_pos_x_i + 7) then
						draw_o <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture;