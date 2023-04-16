library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY routing IS
	PORT(
	flit : IN std_logic_vector(11 downto 0); --come from arbiter
	current : IN integer;
	local_direction, north_direction, south_direction, east_direction, west_direction : OUT std_logic);
END routing;

ARCHITECTURE YX OF routing IS
	SIGNAL local, north, south, east, west : std_logic;
	SIGNAL x_destination, y_destination : INTEGER;
	SIGNAL x_node, y_node : INTEGER;

BEGIN

	x_destination <= to_integer(unsigned(flit(5 DOWNTO 2))) mod 4 ;
	y_destination <= to_integer(unsigned(flit(5 DOWNTO 2))) / 4 ;

		x_node <= current mod 4;
		y_node <= current / 4;
		
	PROCESS (x_node, y_node, x_destination, y_destination)
	BEGIN
	
		north <= '0';
		south <= '0';
		east <= '0';
		west <= '0';
		local <= '0';
	
	
		
		IF (x_node < x_destination) THEN
			east <= '1';
		ELSIF (x_node > x_destination) THEN
			west <= '1';
		ELSE
			IF (y_node < y_destination) THEN
				south <= '1';
			ELSIF (y_node > y_destination) THEN
				north <= '1';
			
			ELSE
				local <= '1';
			END IF;
		END IF;
		
		
	END PROCESS;
	
	local_direction <= local; --local age 0 bashe yani vase on node nist age 1 bashe yani bayad bere tu porte local e on node
	north_direction <= north;
	south_direction <= south;
	east_direction <= east;
	west_direction <= west;
	
END YX;
