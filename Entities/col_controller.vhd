library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity col_controller is
	port(
		clk	: in	std_logic;
		rst	: in	std_logic;
		
		kill_alien_o	: out	std_logic;
		
		alien_pos_x_i	: in	integer;
		alien_pos_y_i	: in	integer;
	);
end entity;

architecture behavior of col_controller is
begin
	process(clk, rst)
		if rising_edge(clk) then
		end if;
	end process;
end architecture;