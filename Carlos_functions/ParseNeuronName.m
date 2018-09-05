function [Channel, SubUnit, NamePart, Channel_ind, SubUnit_ind] = ParseNeuronName(Name);
% ------------------------------------------------------------------------------
% ParseNeuronName	Get the name, channel, and SubUnit in the neuron's string Name
%
%	Usage:
%		[Channel, SubUnit, NamePart, Type] = ParseNeuronName(Name)
%
%	Input:
%		Name		string containing the name of a neuron. Current
%					name formats that are supported:
%
%						Chan015b	Second cell cut on channel 15
%									NOTE: Chan can be a string of any length
%
%						nr_002_03	Third cell cut on channel 2
%									NOTE: nr can be a string of any length,
%									and the first "_" is optional
%
%						Chan015		Unspecified data from channel 15
%									NOTE: Chan can be a string of any length
%									Added March 2005 in support of
%									read_NEVorPLX.m in the event of missing
%									channels, in which case channel IDs can
%									only be determined by parsing the
%									EntityInfo.EntityLabel text field.
%
%						elec1		Found this name in an unedite NEV file.
%									Identified as 5 or 6 element name ending
%									in one or two digits and starting with 
%									"elec". That ought to pin it down.
%
%						digin		Not a neuron, but when cycling through
%									entities in a NEV file, this label will
%									be encountered. I return a channel of -1
%									
%
%	Outputs:
%		Channel		integer specifying the hardware channel
%		SubUnit		integer specifying which isolated unit this in
%						on the channel.
%						1 thru 8	Normal sorted units
%						0			Name indicates unsorted spikes
%						-1			Name indicates invalid spikes.
%						-2			Name does not specify unit number
%					Thus sorted units can be identified using
%					SubUnit > 0. I do not know of any file formats that
%					include invalid waveforms in the naming convention.
%
%		NamePart	string containing the leading characters in Name
%						preceding characters that identify the channel
%						and SubUnit
%
%		Channel_ind	vector of integers which are the indices into the
%						string Name where the Channel number characters
%						can be found. str2num(Name(Channel_ind)) == Channel
%
%		SubUnit_ind	vector of integers which are the indices into the
%						string Name where the cell cut ID characters
%						can be found. Note that Name(SubUnit_ind)
%						may be a character or string, whereas the returned
%						parameter SubUnit will always be translated to
%						integer. When a name is parsed containing no
%						SubUnit indicator, I put a '.' character in the
%						Name(SubUnit_ind) vector.
%
%
%	John Simeral September 2004
% ------------------------------------------------------------------------------
% Note that the name is NOT deblanked first; this makes sure that the
% indices into Name returned by this function will produce the expected characters
% if applied to the original Name
NameLen = length(Name);
LastChar = Name(NameLen);
ThirdCharFromEnd = Name(NameLen-2);		% likely '_' character
if NameLen > 6
	SeventhCharFromEnd = Name(NameLen-6);	% possible first '_' character
else
	SeventhCharFromEnd = '\';	% just give it a junk name
end;

% ------------------------------------------------------------------------------
% Algorithm 1:
%	If the last character is a non-numeric string character (it may be 'i')
% 	then this algorithm is applied.
%
%			Chan015b	Second cell cut on channel 15
%						NOTE: Chan can be a string of any length,
%						but the last character must be a non-digit
%						character or 'i' and the numberic part must be
%						exactly the prior 3 digits.
% ------------------------------------------------------------------------------
if isempty(str2num(LastChar))
	if strcmp('digin',Name)
		NamePart = 'digin'
		Channel_ind = [];
		SubUnit_ind = [];
		Channel = -1;		% there is not channel 
		SubUnit_ind = -1;	% there is no Unit ID, but my code needs a vector entry
		SubUnit = -1;		% my code indicating that the name contains no Unit ID
	elseif NameLen < 4
		error('Algorithm 1: The neuron name "%s" can not be parsed by ParseNeuron.m',Name);
	else
		NamePart = Name(1:NameLen-4);
		Channel_ind = [NameLen-3 : NameLen-1];
		Channel = str2num(Name(Channel_ind));
		SubUnit_ind = [NameLen];
		SubUnitChar = lower(Name(SubUnit_ind));
		if strcmp(SubUnitChar,'i')
			SubUnit = 0;
		else
			% this coverts the lower case letter into its numeric
			% subunit number using its ascii code
			SubUnit	= double(SubUnitChar) - 96;
		end;
	end;

% ------------------------------------------------------------------------------
% Algorithm 2:
%	If the last character converts into an integer and the third character from
%	the end is '_', then this algorithm is applied.
%
%			nr_002_03	Third cell cut on channel 2
%						NOTE: nr can be a string of any length and the
%						first "_" is optional. However, the third character
%						from the end MUSt be '_' to distinguish it from
%						Algorithm 3.
%
%		A special case is required to identify and exclude units identified
%		by SubUnit 'i' (e.g. some unsorted or invalid units), since str2num('i')
%		returns an imaginary number	that passes an isnumeric? test.
% ------------------------------------------------------------------------------
elseif ~isempty(str2num(LastChar)) & isreal(str2num(LastChar)) & strcmp('_',ThirdCharFromEnd)
	if NameLen < 7
		error('Algorithm 2: The neuron name "%s" can not be parsed by ParseNeuron.m',Name);
	end;
	if strcmp('_',SeventhCharFromEnd)
		LastNameInd = NameLen - 7;	% exclude '_' from channel name, if present
	else
		LastNameInd = NameLen - 6;
	end;
	NamePart = Name(1:LastNameInd);
	Channel_ind = [NameLen-5 : NameLen-3];
	Channel = str2num(Name(Channel_ind));
	SubUnit_ind = [NameLen-1:NameLen];
	SubUnit = str2num(Name(SubUnit_ind));

elseif ~isempty(str2num(LastChar)) & isreal(str2num(LastChar)) & ( strcmp('elec',Name(1:4)) | strcmp('chan',Name(1:4)))
% ------------------------------------------------------------------------------
% Algorithm 3:
%	If the last character converts into an integer and the first four characters 
%	of the name are "elec" then this algorithm is applied.
%
%			elec1		Unspecified entity from Channel 1
%			elec57		Unspecified entity from Channel 57
% ------------------------------------------------------------------------------
	NamePart = Name(1:4);
	Channel_ind = [5 : NameLen];
	Channel = str2num(Name(Channel_ind));
	SubUnit_ind = -1;	% there is no Unit ID, but my code needs a vector entry
	SubUnit = -1;		% my code indicating that the name contains no Unit ID

% ------------------------------------------------------------------------------
% Algorithm 4:
%	If the last character converts into an integer and the third character from
%	the end is NOT '_', then this algorithm is applied.
%
%			Chan003		Unspecified entity from Channel 3.
%						NOTE: Chan can be a string of any length but the
%						final three characters must ALL be digits.
% ------------------------------------------------------------------------------
else
	if NameLen < 4
		error('Algorithm 3: The neuron name "%s" can not be parsed by ParseNeuron.m',Name);
	end;
	NamePart = Name(1:NameLen-3);
	Channel_ind = [NameLen-2 : NameLen];
 	Channel = str2num(Name(Channel_ind));
	SubUnit_ind = -1;	% there is no Unit ID, but my code needs a vector entry
	SubUnit = -1;		% my code indicating that the name contains no Unit ID
end;

% ------------------------------------------------------------------------------
% If the algorithm generated non-numeric Channel or SubUnit, then flag
% error.
% ------------------------------------------------------------------------------
if isempty(Channel) | isempty(SubUnit)
	error('Exit: The neuron name "%s" can not be parsed by ParseNeuron.m',Name);
end;

% END