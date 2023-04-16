library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_NODE is
PORT(
	clk, reset: IN std_logic;
	w_en_north, w_en_south, w_en_east, w_en_west, w_en_local: IN std_logic;
	fifo_in_north, fifo_in_south, fifo_in_east, fifo_in_west, fifo_in_local: IN std_logic_vector(11 DOWNTO 0);
	r_en_north, r_en_south, r_en_east, r_en_west, r_en_local: IN std_logic;
	full_north, full_south, full_east, full_west, full_local : OUT std_logic;
	empty_north, empty_south, empty_east, empty_west, empty_local : OUT std_logic;
	fifo_out_north, fifo_out_south, fifo_out_east, fifo_out_west, fifo_out_local: OUT std_logic_vector(11 DOWNTO 0)
	
);
END FIFO_NODE;

ARCHITECTURE beh OF FIFO_NODE IS
	COMPONENT FIFO_BUFFER PORT(
		clk,reset,wr,rd :in std_logic;
		w_data : in std_logic_vector(11 downto 0);
		full, empty : out std_logic;
		r_data : out std_logic_vector(11 downto 0)
	);
	END COMPONENT;
begin
	buffer_north: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_north, rd => r_en_north,
		w_data => fifo_in_north,
		full => full_north,
		empty => empty_north,
		r_data => fifo_out_north
	);
	
	buffer_south: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_south, rd => r_en_south,
		w_data => fifo_in_south,
		full => full_south,
		empty => empty_south,
		r_data => fifo_out_south
	);
	
	buffer_east: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_east, rd => r_en_east,
		w_data => fifo_in_east,
		full => full_east,
		empty => empty_east,
		r_data => fifo_out_east
	);
	
	buffer_west: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_west, rd => r_en_west,
		w_data => fifo_in_west,
		full => full_west,
		empty => empty_west,
		r_data => fifo_out_west
	);
	
	buffer_local: FIFO_BUFFER PORT MAP(
		clk => clk, reset => reset,
		wr => w_en_local, rd => r_en_local,
		w_data => fifo_in_local,
		full => full_local,
		empty => empty_local,
		r_data => fifo_out_local
	);
END beh;