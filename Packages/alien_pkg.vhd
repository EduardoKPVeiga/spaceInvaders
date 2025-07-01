library ieee;
use ieee.std_logic_1164.all;
use work.resolution_pkg.all;

---------------------------------------------------------------------------

-- Aliens attributes

---------------------------------------------------------------------------

package alien_pkg is
	-- Grid layout constants
	constant QT_ALIENS_PER_LINE	: integer	:= 9;
	constant QT_LINES					: integer	:= 3;
   constant QT_ALIENS				: integer	:= QT_ALIENS_PER_LINE * QT_LINES;
	
	-- Alien physical dimensions and movement
	constant ALIEN_WIDTH		: integer	:= 20; -- Increased for better visibility
	constant ALIEN_HEIGHT		: integer	:= 15; -- Increased for better visibility
	constant ALIEN_SPACING_X	: integer	:= 15; -- Horizontal space between aliens
	constant ALIEN_SPACING_Y	: integer	:= 15; -- Vertical space between aliens
	constant ALIEN_MOVE_IT		: integer	:= 4;
	
	-- Game boundaries
	constant END_LINE			: integer	:= RES_HEIGHT - 50; -- Adjusted end line
	constant START_Y_OFFSET		: integer	:= 50; -- Initial vertical offset from top of screen
end package alien_pkg;