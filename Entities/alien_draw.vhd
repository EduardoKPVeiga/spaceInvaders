library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.alien_pkg.all; -- For ALIEN_WIDTH and ALIEN_HEIGHT
use work.resolution_pkg.all; -- For RES_WIDTH/HEIGHT if needed

entity alien_draw is
	port(
		-- Alien state
		alien_pos_x_i	: in	integer;
		alien_pos_y_i	: in	integer;
		is_alive_i      : in    std_logic; -- New input to control drawing

		-- VGA signals
		vga_driver_x_i	: in	std_logic_vector(9 downto 0);
		vga_driver_y_i	: in	std_logic_vector(9 downto 0);
		
		-- Output
		draw_o	: out	std_logic
	);
end alien_draw;

architecture behavior of alien_draw is
	-- Internal signals to hold integer versions of the VGA coordinates
	signal vga_x	: integer range 0 to RES_WIDTH;
	signal vga_y	: integer range 0 to RES_HEIGHT;
begin 
	-- Concurrently convert std_logic_vector inputs to integers
	vga_x <= to_integer(unsigned(vga_driver_x_i));
	vga_y <= to_integer(unsigned(vga_driver_y_i));
	
	-- This process determines if a pixel should be drawn for the alien.
    -- It's combinatorial, so it reacts instantly to changes in VGA counters.
	draw_proc: process(vga_x, vga_y, alien_pos_x_i, alien_pos_y_i, is_alive_i)
	begin
		-- Default to not drawing
		draw_o <= '0';

		-- Only proceed with drawing logic if the alien is alive
		if is_alive_i = '1' then
			-- First, check if the current VGA pixel is within the alien's bounding box.
			if (vga_y >= alien_pos_y_i) and (vga_y < alien_pos_y_i + ALIEN_HEIGHT) and
				(vga_x >= alien_pos_x_i) and (vga_x < alien_pos_x_i + ALIEN_WIDTH) then
			
				-- If inside the box, check against the detailed alien bitmap
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
	end process draw_proc;
end architecture;
