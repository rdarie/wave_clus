function [sFileInfo] = ScanFile_ns(filename);
% ------------------------------------------------------------------------------
% ScanFile_ns		Read header and other information about a NEV or PLX file
%					Report the information to the screen and return it in 
%					structure sFileInfo. Uses high-speed Neuroshare library.
%
% 	Usage:
%		[sFileInfo, file_h] = ScanFile(filename);
%
% 	Inputs:
%		filename		The PLX or NEV file to be read (full path and extension)
%						It is a string previously aquired.
%
% 	Outputs:
%		sFileInfo		Structure with required data about the file required by
%						other neuroshare routines. Includes the handle to the file.
%
%
% John D. Simeral 
% 		February 2004
% 		Modified June 2005
% ---------------------------------------------------------------------------------------
fprintf('\nScanning %s...\n',filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% commented out by cvi
% % -------------------------------------------------------------------------------
% % KLUDGE FOR NEUROSHARE LAMENESS
% %	REQUIRES MACHINE-by-MACHINE adjustment !!
% %
% %	specify the path to the PLX and or NEX DLL (I assume they're in the same
% %	directory). Include the trailing "\" :
% % -------------------------------------------------------------------------------
% DLL_Path = 'D:\jsimeral\Matlab\Neuroshare\';
% 
% % ---------------------------------------
% % LOAD NEX or PLX DLL as appropriate
% % ---------------------------------------
% [T,extension] = strtok(filename,'.');
% while length(extension) > 4
% 	[T,extension] = strtok(extension,'.');
% end;
% extension(1) = [];
% 
% if strcmpi(extension,'plx')
% 	DLLName = [DLL_Path 'nsPlxLibrary.dll'];
% elseif strcmpi(extension,'nev')
% 	DLLName = [DLL_Path 'nsNEVLibrary.dll'];
% else
% 	fprintf('Error in : ScanFile_ns.m: \n');
% 	fprintf('Only NEV and PLX formats are supported. \n');
% 	fprintf('Download a neuroshare DLL to add support for other formats. \n');
% 	return;
% end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% added by CVI
% [libname, libpath] = uigetfile('*.dll', ':::: Please find nsNEVLibrary.dll or  nsPLXLibrary.dll ...');
% DLLName = strcat(libpath, libname);
% 
% extension = DLLName(end-15:end);
% if ~strcmpi(extension,'nsNEVLibrary.dll') & ~strcmpi(extension,'nsPLXLibrary.dll')
% 	fprintf('Error in : ScanFile_ns.m: \n');
% 	fprintf('Only NEV and PLX formats are supported. \n');
% 	fprintf('Download a neuroshare DLL to add support for other formats. \n');
% 	return;
% end;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Load the appropriate DLL
% fprintf('    Loading:   %s...',DLLName);
% [nsresult] = ns_SetLibrary(DLLName);
% fprintf('  OK\n');

% -------------------------------------------
% Open and scan the data file
%	Note that any nsresult ~=0 is an error
% -------------------------------------------
fprintf('    Scanning:   %s...',filename);

[nsresult, file_h] = ns_OpenFile(filename); nsresult
[nsresult, FileInfo] = ns_GetFileInfo(file_h); 
[nsresult, EntityInfo] = ns_GetEntityInfo(file_h, [1 : FileInfo.EntityCount]);
SegmentEntityIDs = find([EntityInfo.EntityType] == 3);	% "off" channels may be missing; may include channels with no waveforms

sFileInfo.file_h = file_h;
sFileInfo.FileInfo = FileInfo;
sFileInfo.EntityInfo = EntityInfo;
sFileInfo.SegmentEntityIDs = SegmentEntityIDs;

fprintf('Done.\n\n');

% END