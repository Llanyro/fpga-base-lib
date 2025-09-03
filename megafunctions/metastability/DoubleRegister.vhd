library ieee;
library llanylib;

use ieee.std_logic_1164.all;
use llanylib.LlanySettings.all;

entity DoubleRegister is
	generic(
		BUS_SIZE	: NAT									:= 1;
	);
	port(
		clk			: in	SL;
		rst			: in	SL;
		data		: in	SLV (BUS_SIZE - 1 downto 0);
		result		: out	SLV (BUS_SIZE - 1 downto 0)		:= (others => '0');
	);
end entity DoubleRegister;

architecture DoubleRegisterArch of DoubleRegister is
	signal prev		: SLV	(BUS_SIZE - 1 downto 0)			:= (others => '0');
begin
	process (clk, rst, data, result)
	begin
		if rst = '1' then
			prev			<= (others => '0');
			result			<= (others => '0');

		elsif rising_edge(clk) then
			prev			<= data;
			result			<= prev;

		end if;
	end process;
end architecture DoubleRegisterArch;