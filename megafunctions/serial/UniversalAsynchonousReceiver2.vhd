library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

entity UniversalAsynchonousReceiver is
	generic(
		BUS_SIZE				: NAT	:= 8;
		TICKS_PER_BIT			: NAT	:= 16
	);
	port(
		tick_source				: in	SL;												-- Baudrate (multiplied by TICKS_PER_BIT)
		rst						: in	SL;												-- Module reset
		bits_recv				: in	NAT	range 3 to BUS_SIZE;						-- Bits desired to recv (min: start + data + stop)
		data_in					: in	SL;												-- Channel to import bits
		valid_data				: out	SL							:= '0';				-- Flag to tell if there is avaible data
		data					: out	SLV (BUS_SIZE - 1 downto 0)	:= (others => '-')	-- Data received
	);
end entity UniversalAsynchonousReceiver;

architecture UniversalAsynchonousReceiverArch of UniversalAsynchonousReceiver is
	constant BUS_SIZE_L			: NAT								:= BUS_SIZE			- 1;
	constant TICKS_PER_BIT_L	: NAT								:= TICKS_PER_BIT	- 1;
	signal internal_data_bit	: SLV1								:= (others => '-');
	signal started				: SL								:= '0';

begin
	internal_data_bit(0)	<= data_in;
	-- Encapsulates signal received
	--double_register	: llanylib.DoubleRegister
	--	generic map(
	--		BUS_SIZE	=> internal_data_bit'lenght;
	--	)
	--	port map(
	--		clk			=> tick_source,
	--		rst			=> rst,
	--		data		=> data_in,
	--		result		=> internal_data_bit
	--	);

	-- Purpose: Control RX state machine
	process (clk)
		variable index			: NAT range 0 to MAX_BUS_SIZE_L			:= 0;	-- Position of bit to get
	begin
		if rst = '1' then
		elsif rising_edge(clk) then
			if index = '0' then					-- No data read yet
				if internal_data_bit = '0' then	-- Start bit detected

				else
				end if;
			else

			end if;
		end if;
	end process;

	valid_data		<= internal_valid_data;
	data		<= internal_data;
end architecture UniversalAsynchonousReceiverArch;