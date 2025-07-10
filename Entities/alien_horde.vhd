-- File: alien_horde.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use work.resolution_pkg.all;
use work.alien_pkg.all;

entity alien_horde is
  generic (
    QT_ALIENS          : integer := 15;
    QT_ALIENS_PER_LINE : integer := 5
  );
  port (
    clk_ctrl      : in  std_logic;
    clk_pix       : in  std_logic;
    rst           : in  std_logic;
    shot_x_i      : in  integer;
    shot_y_i      : in  integer;
    shot_active_i : in  std_logic;
    h_cnt_i       : in  std_logic_vector(9 downto 0);
    v_cnt_i       : in  std_logic_vector(9 downto 0);
    horde_pixel_o : out std_logic;
    game_over_o   : out std_logic;
    win_o         : out std_logic
  );
end entity;

architecture rtl of alien_horde is
  subtype idx_t is integer range 0 to QT_ALIENS-1;
  type int_arr  is array(idx_t) of integer;
  type bool_arr is array(idx_t) of std_logic;

  signal pos_x_s       : int_arr := (others => 0);
  signal pos_y_s       : int_arr := (others => 0);
  signal alive_s       : bool_arr := (others => '1');
  signal turn_s        : bool_arr := (others => '0');
  signal game_over_s   : bool_arr := (others => '0');
  signal collision_s   : bool_arr := (others => '0');

  signal ctrl_down     : std_logic;
  signal ctrl_left     : std_logic;
  signal ctrl_right    : std_logic;
  signal ctrl_game_over: std_logic;

  signal any_turn      : std_logic;
  signal any_game_over : std_logic;
  signal all_dead      : std_logic;

  signal game_over_flag: std_logic := '0';
  signal win_flag      : std_logic := '0';

begin
  any_turn      <= '1' when turn_s /= (turn_s'range => '0') else '0';
  any_game_over <= '1' when game_over_s /= (game_over_s'range => '0') else '0';
  all_dead      <= '1' when alive_s = (alive_s'range => '0')     else '0';

  controller_inst: entity work.alien_controller
    port map(
      clk         => clk_ctrl,
      rst         => rst,
      turn_i      => any_turn,
      game_over_i => game_over_flag,
      down_o      => ctrl_down,
      left_o      => ctrl_left,
      right_o     => ctrl_right,
      game_over_o => ctrl_game_over
    );

  ALIEN_GEN: for i in 0 to QT_ALIENS-1 generate
    constant row : integer := i / QT_ALIENS_PER_LINE;
    constant col : integer := i mod QT_ALIENS_PER_LINE;
    constant init_x : integer := col * (ALIEN_WIDTH  + 8) + 32;
    constant init_y : integer := row * (ALIEN_HEIGHT + 8) + 16;

    alien_inst: entity work.alien
      generic map(init_pos_x=>init_x, init_pos_y=>init_y)
      port map(
        clk         => clk_ctrl,
        rst         => rst,
        down_i      => ctrl_down,
        left_i      => ctrl_left,
        right_i     => ctrl_right,
        game_over_i => ctrl_game_over,
        die         => collision_s(i),
        pos_x_o     => pos_x_s(i),
        pos_y_o     => pos_y_s(i),
        is_alive_o  => alive_s(i),
        turn_o      => turn_s(i),
        game_over_o => game_over_s(i)
      );

    draw_inst: entity work.alien_draw
      port map(
        alien_pos_x_i  => pos_x_s(i),
        alien_pos_y_i  => pos_y_s(i),
        is_alive_i     => alive_s(i),
        vga_driver_x_i => h_cnt_i,
        vga_driver_y_i => v_cnt_i,
        draw_o         => turn_s(i)
      );

    coll_inst: entity work.collision_controller
      port map(
        shot_x_i         => shot_x_i,
        shot_y_i         => shot_y_i,
        shot_active_i    => shot_active_i,
        alien_x_i        => pos_x_s(i),
        alien_y_i        => pos_y_s(i),
        alien_is_alive_i => alive_s(i),
        collision_o      => collision_s(i)
      );
  end generate;

  process(clk_ctrl)
  begin
    if rising_edge(clk_ctrl) then
      if rst = '1' then
        game_over_flag <= '0';
        win_flag       <= '0';
      else
        if any_game_over = '1' then game_over_flag <= '1'; end if;
        if all_dead = '1' then win_flag <= '1'; end if;
      end if;
    end if;
  end process;

  game_over_o <= game_over_flag;
  win_o       <= win_flag;

  process(clk_pix)
    variable pix : std_logic := '0';
  begin
    if rising_edge(clk_pix) then
      pix := '0';
      for j in 0 to QT_ALIENS-1 loop
        pix := pix or turn_s(j);
      end loop;
      horde_pixel_o <= pix;
    end if;
  end process;

end architecture;
