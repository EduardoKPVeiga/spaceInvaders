library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alien_pkg.all; -- For ALIEN_WIDTH and ALIEN_HEIGHT

-- This entity checks for a collision between a single shot and a single alien.
entity collision_controller is
    port(
        -- Shot properties (to be connected from your upcoming shot module)
        shot_x_i        : in    integer;
        shot_y_i        : in    integer;
        shot_active_i   : in    std_logic;

        -- Alien properties
        alien_x_i       : in    integer;
        alien_y_i       : in    integer;
        alien_is_alive_i: in    std_logic;

        -- Output
        collision_o     : out   std_logic -- '1' if a collision occurs
    );
end entity;

architecture behavior of collision_controller is
    -- For this implementation, the shot is treated as a single pixel.
    -- If your shot has its own width and height, you can add them to the
    -- bounding box calculation.
begin

    -- This is a purely combinatorial process. It continuously checks for a collision.
    collision_check_proc: process(shot_x_i, shot_y_i, shot_active_i, alien_x_i, alien_y_i, alien_is_alive_i)
    begin
        -- Default to no collision
        collision_o <= '0';

        -- A collision can only happen if a shot is active and the alien is still alive.
        if shot_active_i = '1' and alien_is_alive_i = '1' then
            
            -- Simple AABB (Axis-Aligned Bounding Box) collision detection.
            -- This checks if the shot's (x,y) coordinate is within the alien's box.
            if  (shot_x_i >= alien_x_i) and
                (shot_x_i < alien_x_i + ALIEN_WIDTH) and
                (shot_y_i >= alien_y_i) and
                (shot_y_i < alien_y_i + ALIEN_HEIGHT) then
                
                -- Collision detected!
                collision_o <= '1';
            end if;
        end if;
    end process collision_check_proc;

end architecture;
