library ieee;
library llanylib;

use ieee.std_logic_1164.ALL;
use llanylib.LlanySettings.all;

entity UniversalAsynchonousTransmitter3Prep is
	generic(
		MAX_BUS_SIZE		: NAT									:= 7;	-- Size range that bus can send data (7 data)
		TICKS_PER_BIT		: NAT									:= 15	-- Number of clock ticks that is needed to complete 1 baud
	);
	port(
		tick_source			: in	SL;										-- 115200 bits second
		rst					: in	SL;										-- Module reset?

		data				: in	SLV (MAX_BUS_SIZE downto 0);			-- Data to send
		bits_to_send		: in	NAT range 1 to MAX_BUS_SIZE;			-- Number of bits to send
		data_valid			: in	SL;										-- If data to send is valid and prepared to be sent
		send_parity			: in	SL;										-- Parity bit (1 to send it)
		extra_stop			: in	SL;										-- Extra stop bit

		data_out			: out	SL								:= '0';	-- Channel to export bits
		active				: out	SL								:= '0'	-- In use, working, sending message
	);
end entity UniversalAsynchonousTransmitter3Prep;

architecture UniversalAsynchonousTransmitter3PrepArch of UniversalAsynchonousTransmitter3Prep is
	constant TOTAL_BITS		: NAT	:= MAX_BUS_SIZE + 1 + 1 + 2;				-- Start, parity, stop
	signal real_data		: SLV (TOTAL_BITS - 1 downto 0)	:= (others => '0');	-- 
	signal real_data_size	: NAT range 1 to MAX_BUS_SIZE;	
begin
	-- Adds start bit + data + parity + stop bits		when requested
	if send_parity = '1' and extra_stop = '0' then
		real_data		<= '1' & data(bits_to_send downto 0) & has_odd_ones(data) & '0';
		real_data_size	<= bits_to_send + 3;
	elsif send_parity = '1' and extra_stop = '1' then
		real_data		<= '1' & data(bits_to_send downto 0) & has_odd_ones(data) & "00";
		real_data_size	<= bits_to_send + 4;
	elsif send_parity = '0' and extra_stop = '0' then
		real_data		<= '1' & data(bits_to_send downto 0) & '0';
		real_data_size	<= bits_to_send + 2;
	elsif send_parity = '1' and extra_stop = '1' then
		real_data		<= '1' & data(bits_to_send downto 0) & "00";
		real_data_size	<= bits_to_send + 3;
	end if;

	uat : llanylib.UniversalAsynchonousTransmitter3
		generic map(
			MAX_BUS_SIZE	=> TOTAL_BITS,
			TICKS_PER_BIT	=> TICKS_PER_BIT
		)
		port map(
			tick_source 	=> tick_source,
			rst				=> rst,
			data			=> data,
			bits_to_send	=> real_data_size,
			data_valid		=> data_valid,
			data_out		=> data_out,
			active			=> active
		);
	
end architecture UniversalAsynchonousTransmitter3PrepArch;
