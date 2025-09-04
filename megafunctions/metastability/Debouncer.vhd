library ieee;
library llanylib;

use ieee.std_logic_1164.all;
use llanylib.LlanySettings.all;

entity Debouncer is
	generic (
		NUMBER_OF_TICKS : NAT 								:= 16							-- 
	);
	port (
		clk				: in  SL;															-- Clock source
		rst				: in  SL;															-- Module reset
		data			: in  SL;															-- Data to debounce (check noise)
		result			: out SL							:= '0'							-- Data processed
	);
end entity Debouncer;

architecture DebouncerArch of Debouncer is
	constant NUMBER_OF_TICKS_L	: NAT								:= NUMBER_OF_TICKS - 1;	--
	signal counter				: NAT range 0 to NUMBER_OF_TICKS_L	:= 0;					-- Current tick
	signal reg					: SL								:= '0';					-- Data with reduced metastability
	signal output_reg			: SL								:= '0';					-- Data to export (if N ticks passed correctly)

begin
	double_register	: llanylib.DoubleRegister
		port map(
			clk		=> clk,
			rst		=> rst,
			data	=> data,
			result	=> reg
		);

	process (clk, rst, data, result)
	begin
		if rst = '1' then
			counter				<= 0;
			output_reg			<= '0';

		elsif rising_edge(clk) then
			if reg /= output_reg then
				counter			<= 0;
			else
				if counter = NUMBER_OF_TICKS_L then
					output_reg	<= reg;
				else counter	<= counter + 1;
				end if;
			end if;
		end if;
	end process;

	result						<= output_reg;
end architecture DebouncerArch;