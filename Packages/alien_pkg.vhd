library ieee;
use ieee.std_logic_1164.all;
use work.resolution_pkg.all;

---------------------------------------------------------------------------

-- Aliens attributes

---------------------------------------------------------------------------

package alien_pkg is
	constant QT_ALIENS_PER_LINE	: integer	:= 9;
	constant QT_LINES					: integer	:= 3;
   constant QT_ALIENS				: integer	:= QT_ALIENS_PER_LINE * QT_LINES;
	constant ALIEN_MOVE_IT			: integer	:= 4;
	constant END_LINE					: integer	:= RES_HEIGHT - 20;
end package alien_pkg;