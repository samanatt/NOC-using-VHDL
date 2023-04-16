library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY router_to_arbiter IS
	PORT(
	clk, reset: IN std_logic;
	current : IN INTEGER; --shomare router
	
	fifo_in_local, fifo_in_west, fifo_in_east, fifo_in_north, fifo_in_south : IN std_logic_vector(11 DOWNTO 0); --input ha az buffere vurudi mian
	
	w_en_north, w_en_south, w_en_east, w_en_west, w_en_local: OUT std_logic;
	
	credit_out_north, credit_out_south, credit_out_east, credit_out_west, credit_out_local: IN std_logic; --signal full buffer haie ke tushun minevisan
	
	empty_in_north, empty_in_south, empty_in_east, empty_in_west, empty_in_local: IN std_logic; --signal e empty buffer hAye vurudi (age khali nabud), signal e request ro tolid mikonan
	
	fifo_out_north, fifo_out_south, fifo_out_east, fifo_out_west, fifo_out_local: OUT std_logic_vector(11 DOWNTO 0); -- ina miran be buffer e khuruji
	
	--r_en_north_out, r_en_south_out, r_en_east_out, r_en_west_out, r_en_local_out: OUT std_logic;
	
	r_en_north_in, r_en_south_in, r_en_east_in, r_en_west_in, r_en_local_in: OUT std_logic
	
	);
	
END router_to_arbiter;

ARCHITECTURE beh_router_to_arbiter OF router_to_arbiter IS
	
	COMPONENT routing PORT(
		flit : IN std_logic_vector(11 downto 0); -- flit i ke az arbiter miad
		current : IN integer;
		local_direction, north_direction, south_direction, east_direction, west_direction : OUT std_logic);
	END COMPONENT;
	
	COMPONENT arbiter PORT(
		clk: in std_logic; reset: in std_logic; 
		r: in std_logic_vector(3 downto 0);
		g: out std_logic_vector(3 downto 0));
	END COMPONENT;
	
	
	-- fifo_in_local routing signals (yani vaghti vurudi az local miad tu node chanta bayad tu kudum jahat harekat kone)
	SIGNAL local_dir_north, local_dir_south, local_dir_east, local_dir_west: std_logic;
	
	-- fifo_in_north routing signals
	SIGNAL north_dir_local, north_dir_south, north_dir_east, north_dir_west: std_logic;

	-- fifo_in_south routing signals
	SIGNAL south_dir_local, south_dir_north, south_dir_east, south_dir_west: std_logic;
	
	-- fifo_in_east routing signals
	SIGNAL east_dir_local, east_dir_north, east_dir_south, east_dir_west: std_logic;
	
	-- fifo_in_west routing signals
	SIGNAL west_dir_local, west_dir_north, west_dir_south, west_dir_east: std_logic;
	
	SIGNAL req_out_north, req_out_south, req_out_east, req_out_west, req_out_local: std_logic_vector(3 DOWNTO 0);
	
	SIGNAL grant_north, grant_south, grant_east, grant_west, grant_local: std_logic_vector(3 DOWNTO 0);
	
	SIGNAL wr_en_north, wr_en_south, wr_en_east, wr_en_west, wr_en_local: std_logic;
	
	SIGNAL wr_data_north, wr_data_south, wr_data_east, wr_data_west, wr_data_local: std_logic_vector(11 DOWNTO 0);
	
	
BEGIN

	------------------------
	-- south
	------------------------
		
	-- south_des_x va south_des_y ro befrest routing direction ro begir
	routing_south: routing PORT MAP(
	current => current,flit => fifo_in_south,
	local_direction => south_dir_local, north_direction => south_dir_north, south_direction => OPEN, 
	east_direction => south_dir_east, west_direction => south_dir_west);
	
	--req_out_south <= (local_dir_south, west_dir_south, east_dir_south, north_dir_south);
	req_out_south(0) <= north_dir_south when (fifo_in_north(11 DOWNTO 10)="00") and (empty_in_north = '0')else '0';
	req_out_south(1) <= east_dir_south when (fifo_in_east(11 DOWNTO 10)="00") and (empty_in_east = '0') else '0';
	req_out_south(2) <= west_dir_south when (fifo_in_west(11 DOWNTO 10)="00") and (empty_in_west = '0') else '0';
	req_out_south(3) <= local_dir_south when (fifo_in_local(11 DOWNTO 10)="00") and (empty_in_local = '0') else '0';

	------------------------
	-- west
	------------------------

		
	-- west_des_x va west_des_y ro befrest routing direction ro begir
	routing_west: routing PORT MAP(
	current => current , flit => fifo_in_west,
	local_direction => west_dir_local, north_direction => west_dir_north, south_direction => west_dir_south, 
	east_direction => west_dir_east, west_direction => OPEN);

	--req_out_west <= (local_dir_west, east_dir_west, south_dir_west, north_dir_west);
	req_out_west(0) <= north_dir_west when (fifo_in_north(11 DOWNTO 10)="00") and (empty_in_north = '0') else '0';
	req_out_west(1) <= south_dir_west when (fifo_in_south(11 DOWNTO 10)="00") and (empty_in_south = '0') else '0';
	req_out_west(2) <= east_dir_west when (fifo_in_east(11 DOWNTO 10)="00") and (empty_in_east = '0') else '0';
	req_out_west(3) <= local_dir_west when (fifo_in_local(11 DOWNTO 10)="00") and (empty_in_local = '0') else '0';

	
	------------------------
	-- east
	------------------------
		
	-- east_des_x va east_des_y ro befrest routing direction ro begir
	routing_east: routing PORT MAP(
	current => current, flit => fifo_in_east,
	local_direction => east_dir_local, north_direction => east_dir_north, south_direction => east_dir_south, 
	east_direction => OPEN, west_direction => east_dir_west);
		
	--req_out_east <= (local_dir_east, west_dir_east, south_dir_east, north_dir_east);
	req_out_east(0) <= north_dir_east when (fifo_in_north(11 DOWNTO 10)="00") and (empty_in_north = '0') else '0';
	req_out_east(1) <= south_dir_east when (fifo_in_south(11 DOWNTO 10)="00") and (empty_in_south = '0') else '0';
	req_out_east(2) <= west_dir_east when (fifo_in_west(11 DOWNTO 10)="00") and (empty_in_west = '0') else '0';
	req_out_east(3) <= local_dir_east when (fifo_in_local(11 DOWNTO 10)="00") and (empty_in_local = '0') else '0';
	------------------------
	--north
	------------------------
		
	-- north_des_x va local_des_y ro befrest routing direction ro begir
	routing_north: routing PORT MAP(
	current => current, flit => fifo_in_north,
	local_direction => north_dir_local, north_direction => OPEN, south_direction => north_dir_south, 
	east_direction => north_dir_east, west_direction => north_dir_west);
		
	--req_out_north <= (local_dir_north, west_dir_north, east_dir_north, south_dir_north);
	req_out_north(0) <= south_dir_north when (fifo_in_south(11 DOWNTO 10)="00") and (empty_in_south = '0') else '0';
	req_out_north(1) <= east_dir_north when (fifo_in_east(11 DOWNTO 10)="00") and (empty_in_east = '0') else '0';
	req_out_north(2) <= west_dir_north when (fifo_in_west(11 DOWNTO 10)="00") and (empty_in_west = '0') else '0';
	req_out_north(3) <= local_dir_north when (fifo_in_local(11 DOWNTO 10)="00") and (empty_in_local = '0') else '0';

	------------------------
	--local
	------------------------
		
	-- local_des_x va local_des_y ro befrest routing direction ro begir
	routing_local: routing PORT MAP(
	current => current, flit => fifo_in_local,
	local_direction => OPEN, north_direction => local_dir_north, south_direction => local_dir_south, 
	east_direction => local_dir_east, west_direction => local_dir_west);
			
	--req_out_local <= (west_dir_local, east_dir_local, south_dir_local, north_dir_local);
	req_out_local(0) <= north_dir_local when (fifo_in_north(11 DOWNTO 10)="00") and (empty_in_north = '0') else '0';
	req_out_local(1) <= south_dir_local when (fifo_in_south(11 DOWNTO 10)="00") and (empty_in_south = '0') else '0';
	req_out_local(2) <= east_dir_local when (fifo_in_east(11 DOWNTO 10)="00") and (empty_in_east = '0') else '0';
	req_out_local(3) <= west_dir_local when (fifo_in_west(11 DOWNTO 10)="00") and (empty_in_west = '0') else '0';
	
	--arbiter e sare buffer e north
	arbiter_north: arbiter PORT MAP(
	clk => clk, reset => reset,
	r => req_out_north, g => grant_north
	);
	
	--arbiter e sare buffer e south
	arbiter_south: arbiter PORT MAP(
	clk => clk, reset => reset,
	r => req_out_south, g => grant_south
	);
	
	--arbiter e sare buffer e east
	arbiter_east: arbiter PORT MAP(
	clk => clk, reset => reset,
	r => req_out_east, g => grant_east
	);
	
	--arbiter e sare buffer e west
	arbiter_west: arbiter PORT MAP(
	clk => clk, reset => reset,
	r => req_out_west, g => grant_west
	);
	
	--arbiter e sare buffer e local
	arbiter_local: arbiter PORT MAP(
	clk => clk, reset => reset,
	r => req_out_local, g => grant_local
	);
------------
------------
	
	-- zamani write enable on buffer faal mishe ke request zade beshe (req_out_), arbiter grant bede
	wr_en_north <= '1' when (grant_north(0)='1' or grant_north(1)='1' or grant_north(2)='1' or grant_north(3)='1') and (credit_out_north = '0') else '0';
	-- arbiter be harki grant dad on datash ro mizare ruye vurudie buffer e maghsad
	wr_data_north<=fifo_in_south when (grant_north(0)='1') else
						fifo_in_east when (grant_north(1)='1') else
						fifo_in_west when (grant_north(2)='1') else
						fifo_in_local when (grant_north(3)='1') else
						(others=>'0');
						
	w_en_north <= wr_en_north;
	fifo_out_north <= wr_data_north;
-----	
						
	wr_en_south <= '1' when (grant_south(0)='1' or grant_south(1)='1' or grant_south(2)='1' or grant_south(3)='1') and (credit_out_south = '0') else '0';
	wr_data_south<=fifo_in_north when (grant_south(0)='1') else
						fifo_in_east when (grant_south(1)='1') else
						fifo_in_west when (grant_south(2)='1') else
						fifo_in_local when (grant_south(3)='1') else
						(others=>'0');
						
	w_en_south <= wr_en_south;
	fifo_out_south <= wr_data_south;
-----
						
	wr_en_east <= '1' when (grant_east(0)='1' or grant_east(1)='1' or grant_east(2)='1' or grant_east(3)='1') and (credit_out_east = '0') else '0';
	wr_data_east<=fifo_in_north when (grant_east(0)='1') else
						fifo_in_south when (grant_east(1)='1') else
						fifo_in_west when (grant_east(2)='1') else
						fifo_in_local when (grant_east(3)='1') else
						(others=>'0');
						
	w_en_east <= wr_en_east;
	fifo_out_east <= wr_data_east;
	
-----	
	wr_en_west <= '1' when (grant_west(0)='1' or grant_west(1)='1' or grant_west(2)='1' or grant_west(3)='1') and (credit_out_west = '0') else '0';
	wr_data_west<=fifo_in_north when (grant_west(0)='1') else
						fifo_in_south when (grant_west(1)='1') else
						fifo_in_east when (grant_west(2)='1') else
						fifo_in_local when (grant_west(3)='1') else
						(others=>'0');
						
	w_en_west <= wr_en_west;
	fifo_out_west <= wr_data_west;

-----	
	wr_en_local <= '1' when (grant_local(0)='1' or grant_local(1)='1' or grant_local(2)='1' or grant_local(3)='1') and (credit_out_local = '0') else '0';
	wr_data_local<=fifo_in_north when (grant_local(0)='1') else
						fifo_in_south when (grant_local(1)='1') else
						fifo_in_east when (grant_local(2)='1') else
						fifo_in_west when (grant_local(3)='1') else
						(others=>'0');
						
	w_en_local <= wr_en_local;
	fifo_out_local <= wr_data_local;
	
	-------------
	-- signal e read e buffer hAye vurudie node (5ta buffer)
	--vaghti be buffere vurudie ye node tavasote arbiterAye jahatAye dige, grant dade mishe signal e read e on buffere vurudi bayad 1 beshe	
	--gn=(l,w,e,s) gs=(l,w,e,n) ge=(l,w,s,n) gw=(l,e,s,n) gl=(w,e,s,n)
	r_en_north_in <= '1' when (grant_south(0)='1' or grant_east(0)='1' or grant_west(0)='1' or grant_local(0)='1') else '0'; 																																									
	r_en_south_in <= '1' when (grant_north(0)='1' or grant_east(1)='1' or grant_west(1)='1' or grant_local(1)='1') else '0';
	r_en_east_in <= '1' when (grant_north(1)='1' or grant_south(1)='1' or grant_west(2)='1' or grant_local(2)='1') else '0';
	r_en_west_in <= '1' when (grant_north(2)='1' or grant_south(2)='1' or grant_east(2)='1' or grant_local(3)='1') else '0';
	r_en_local_in <= '1' when (grant_north(3)='1' or grant_south(3)='1' or grant_east(3)='1' or grant_west(3)='1') else '0';
	
	-----------
	-- signal e read e buffer hAye khuruji node (5ta buffer) 
	-- vaghti faal mishe ke arbitere on khuruji be yeki signal e grant dade bashe (yeki az bit hAye on grant 1 beshe)
	--gn=(l,w,e,s) gs=(l,w,e,n) ge=(l,w,s,n) gw=(l,e,s,n) gl=(w,e,s,n)
	--r_en_north_out <= '1' when (grant_north(0)='1' or grant_north(1)='1' or grant_north(2)='1' or grant_north(3)='1') else '0'; --vaghti be buffere vurudie ye node tavasote arbiterAye jahatAye dige, grant dade mishe signal e read e on buffere vurudi bayad 1 beshe																																										
	--r_en_south_out <= '1' when (grant_south(0)='1' or grant_south(1)='1' or grant_south(2)='1' or grant_south(3)='1') else '0';
	--r_en_east_out <= '1' when (grant_east(0)='1' or grant_east(1)='1' or grant_east(2)='1' or grant_east(3)='1') else '0';
	--r_en_west_out <= '1' when (grant_west(0)='1' or grant_west(1)='1' or grant_west(2)='1' or grant_west(3)='1') else '0';
	--r_en_local_out <= '1' when (grant_local(0)='1' or grant_local(1)='1' or grant_local(2)='1' or grant_local(3)='1') else '0';		

	
END beh_router_to_arbiter;
	