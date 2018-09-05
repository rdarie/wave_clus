function [Waves, TimeStamps, unitIDs] = ReadWaves_ns(sFI, Channel);
% ------------------------------------------------------------------------------
% ReadWaves_ns		Read waveforms from the specified channel of a NEV or PLX file.
%					Return the waveforms in matrix Waves and the vector of
%					timestamps in TimeStamps. Uses high-speed Neuroshare library.
%					This code ignores any unit ID information (i.e. previous sort
%					information) except that waveforms from invalid units are
%					excluded.
%
% Usage:
%		[Waves, TimeStamps] = ReadWaves_ns(sFI, Channel);
%
% Inputs:
%		sFI			Structure of FileInfo containing needed information
%					about the source file. Get this by running ScanFile_ns.m
%					Required parts here are:
%						file_h
%						EntityInfo
%						SegmentEntityIDs
%
%		Channel		scaler specifying which channel to load waveforms from
%					Must be a scalar intstead of a vector of channels because
%					this code is intended to operate on just one channel.
%
%	Outputs:
%		Waves			matrix [samplepoints x numwaves] of waveforms
%
%	 	TimeStamps		column vector of timestamps, one for each waveform
%
% John D. Simeral February 2004
% modified June 2005
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Find the entity ID that corresponds with the requested channel.
%		We can NOT assume that the EntityID == channel. Instead, we have
%		to parse the Entity label (according to Kirk Korver).
% ------------------------------------------------------------------------------
for n = 1:length(sFI.SegmentEntityIDs)
	EntityID = sFI.SegmentEntityIDs(n);

    if (EntityID<128)
	[ThisEntityParsedChannel(n)] = ParseNeuronName(sFI.EntityInfo(EntityID).EntityLabel);
    end
    
end;
CorrectEntityID = sFI.SegmentEntityIDs(ThisEntityParsedChannel == Channel);

% ------------------------------------------------------------------------------
% Read the waveforms
% ------------------------------------------------------------------------------
NumWaves = sFI.EntityInfo(CorrectEntityID).ItemCount;
WavesToLoad = [1:NumWaves];
fprintf('Reading %i waveforms for channel %i...',length(WavesToLoad), Channel);
[nsresult, TimeStamps, Waves, sampleCount, unitIDs] = ns_GetSegmentData(sFI.file_h, CorrectEntityID,WavesToLoad);

% ------------------------------------------------------------------------------
% Exclude invalid waveforms:
% ------------------------------------------------------------------------------
indices_to_remove = find(unitIDs == 255);
TimeStamps(indices_to_remove) = [];
Waves(:,indices_to_remove) = [];

fprintf(' Done.\n');

% END