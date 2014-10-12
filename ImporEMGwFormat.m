% FFTPower() - Performs Fast Fourier Tranformations on continuous or
% segmented data.
%
% Usage:
%   >>  EEG = FFTPower( EEG, FFTChs );
% Inputs:
%   EEG     - EEG dataset.
%   FFTChs  - Channels on which to perform FFT.
%    
% Outputs:
%   EEG     - EEG dataset.
%
% See also: 
%   POP_FFTPower, EEGLAB 

% Copyright (C) <2006>  <James Desjardins> <Brock University>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function EEG = ImportEMGworksFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportEMGworksFormat;
	return;
end;	



%eval(['fidEMGwF=fopen(''' FilePath FileName ''',''r'');']);






%function [header, data] = loademg3(filename);
% LOADEMG3 reads the EMG data file specified in filename.
% Returns the Emg data in the variable data, which is a [channels,samples] matrix.
% header contains a description of the data acquisition setup.
% Returns -1 if file couldn't be opened.
% Example:
% >> [header, data]=loademg3('test.emg');

% Copyright 2003 Delsys Inc.
% 03/11/03 Version 1.0
% 03/11/03 Version 1.1 
%           Replaced fgets with char(fread(fId,255,'char'))' to prevent inadvertent reading of string terminator
% 03/18/03 Version 1.2
%           Changed FileId to 'DEMG' and version to uint16 for backwards compatibility.
% 04/30/03 Version 1.3
%           Added more comments.
% 05/20/03 Version 1.4 
%           Fixed issues with reading to many points
% 06/25/03 Version 1.5
%           Added support for old EMG file format




data = -1; % Default value
fId=fopen(CStr(FilePath FileName),'r','n');
if fId>0
   % Read in header information
   header.ID= fgets(fId,4);                                                         % File ID
   % Verify the file ID
   if header.ID == 'DEMG'
       fprintf(1, 'Reading file %s...\n',filename);        
       
       header.Version = fread(fId,1,'uint16');                                      % File version
       
       % Read old file format
       if header.Version  == 1 | header.Version  == 2
           header.FileType = 0;                                 % FileType (0 = RAW data)
           header.EMGworksVersion = '';                         % EMGworks Version ("1.0.0.0")
           header.DADLLversion = '';                            % DADLL Version ("1.0.0.0")
           header.CardManufacturer = '';                        % A/D card Manufacturer
           header.ADCardID = [];                                % A/D card Identifier
           header.ESeries = [];                                  % National Instruments E-Series Card? (0 = NO, 1 = YES)
           header.Channels = fread(fId,1,'unsigned short');     % Number of channels
           header.Fs= fread(fId,1,'unsigned long');             % Actual sampling frequency
           header.Samples = fread(fId,1,'unsigned long');       % Actual number of samples
           header.SamplesDesired = [];                          % Desired number of samples
           header.FsDesired = header.Fs;                        % Desired sampling frequency 
           header.DataStart = [];                              % Data start point in the file (byte count)
           header.TriggerStart = [];                             % Start Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
           header.TriggerStop = [];                              % Stop Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
           header.DaqSingleEnded = [];                           % Single ended Daq mode (1 = Single ended)
           header.DaqBipolar = [];                               % Bipolar ended Daq mode (1 = Bipolar)
           header.UseCamera = 0;                                % Camera use (0 = NO, 1 = YES)
           %strLength = fread(fId,1,'uint32'); 
           header.VideoFilename = '';                           % Associated Video File name
           % Read in Channel info
           for i = 1 : header.Channels
               header.ChannelInfo(i).Channel = i;               % Channel number (one based) 
               % strLength = fread(fId,1,'uint32'); 
               header.ChannelInfo(i).Unit = '';                 % Unit
               % strLength = fread(fId,1,'uint32'); 
               header.ChannelInfo(i).Label = ['Ch' int2str(i)]; % Label
               header.ChannelInfo(i).SystemGain = [];           % System Gain
               header.ChannelInfo(i).ADGain = [];               % AD Gain
               header.ChannelInfo(i).BitResolution = [];        % Bit resolution
               header.ChannelInfo(i).Bias = [];                 % System Bias
               header.ChannelInfo(i).HP = [];                   % High Pass cutoff frequency
               header.ChannelInfo(i).LP = [];      
           end%for i = 1 : header.Channels
           % read the data
           resolution=fread(fId,1,'char');%
           vMin=fread(fId,1,'schar');%
           vMax=fread(fId,1,'schar');%
           switch header.Version
               case 1	%data stored as floats
                   data=fread(fId,[header.Channels,header.Samples],'float');	% read the emg matrix in
               case 2	%data stored as uints
                   data=fread(fId,[header.Channels,header.Samples],'uint16');	% read the emg matrix in
                   data=data/(2^resolution-1)*(vMax-vMin) + vMin;			% scale the data	
           end
       
       elseif header.Version == 3
           % Read the rest of the header.
           header.FileType = fread(fId,1,'uint32');                                 % FileType (0 = RAW data)
           header.EMGworksVersion = char(fread(fId,11,'char'))';                    % EMGworks Version ("1.0.0.0")
           header.DADLLversion = char(fread(fId,11,'char'))';                       % DADLL Version ("1.0.0.0")
           header.CardManufacturer = char(fread(fId,255,'char'))';                  % A/D card Manufacturer
           header.ADCardID = fread(fId,1,'uint32');                                 % A/D card Identifier
           header.ESeries = fread(fId,1,'uint32');                                  % National Instruments E-Series Card? (0 = NO, 1 = YES)
           header.Channels = fread(fId,1,'uint32');                                 % Number of channels
           header.Samples = fread(fId,1,'uint32');                                  % Actual number of samples
           header.SamplesDesired = fread(fId,1,'uint32');                           % Desired number of samples
           header.Fs= fread(fId,1,'double');                                        % Actual sampling frequency
           header.FsDesired = fread(fId,1,'double');                                % Desired sampling frequency 
           header.DataStart = fread(fId,1,'uint32');                                % Data start point in the file (byte count)
           header.TriggerStart = fread(fId,1,'uint32');                             % Start Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
           header.TriggerStop = fread(fId,1,'uint32');                              % Stop Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
           header.DaqSingleEnded = fread(fId,1,'uint32');                           % Single ended Daq mode (1 = Single ended)
           header.DaqBipolar = fread(fId,1,'uint32');                               % Bipolar ended Daq mode (1 = Bipolar)
           header.UseCamera = fread(fId,1,'uint32');                                % Camera use (0 = NO, 1 = YES)
           strLength = fread(fId,1,'uint32'); 
           header.VideoFilename = char(fread(fId,strLength,'char'))';               % Associated Video File name
           % Read in Channel info
           for i = 1 : header.Channels
               header.ChannelInfo(i).Channel = fread(fId,1,'uint32');               % Channel number (one based) 
               strLength = fread(fId,1,'uint32'); 
               header.ChannelInfo(i).Unit = char(fread(fId,strLength,'char'))';     % Unit
               strLength = fread(fId,1,'uint32'); 
               header.ChannelInfo(i).Label = char(fread(fId,strLength,'char'))';    % Label
               header.ChannelInfo(i).SystemGain = fread(fId,1,'double');            % System Gain
               header.ChannelInfo(i).ADGain = fread(fId,1,'double');                % AD Gain
               header.ChannelInfo(i).BitResolution = fread(fId,1,'double');         % Bit resolution
               header.ChannelInfo(i).Bias = fread(fId,1,'double');                  % System Bias
               header.ChannelInfo(i).HP = fread(fId,1,'double');                    % High Pass cutoff frequency
               header.ChannelInfo(i).LP = fread(fId,1,'double');                    % Low Pass cutoff frequency
           end    
           % Read the data.
           data = fread(fId,[header.Channels, header.Samples], 'int16');%
           
           % Scale the data
           for i = 1 : header.Channels
               data(i,:) = (data(i,:) / header.ChannelInfo(i).ADGain * 5 / 2^15 - header.ChannelInfo(i).Bias) /  header.ChannelInfo(i).SystemGain;  
           end
       else
           fprintf(1, 'Uknown file version for file %s\n',filename);
       end
   else %if header.ID == 'DEMG'
       fprintf(1, 'File %s is not a proper EMG file\n',filename);
       header=[];  % need to return something otherwise error message
       data = [];  
   end %if header.ID == 'DEMG'
   fclose(fId);
else
    fprintf(1, 'File %s not found !!!\n',filename);
    header=[];  % need to return something otherwise error message
    data = [];  
end

  









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%FileDouble=fread(fidIEF,'char');

%CRs=find(FileDouble==13);
%Header=char(FileDouble(1:CRs(1)-1)');

%commas=find(Header==',');

%for i=1:length(Header)-20;
%    if Header(i:i+13)=='files_averaged';
%        EEG.NTrialsUsed=str2num(Header(commas(1):i-1));
%    end
%    if Header(i:i+5)=='trials';
%        EEG.NTrialsUsed=str2num(Header(commas(1):i-1));
%    end
%    
%    if Header(i:i+11)=='NptsPerEpoch';
%        EEG.pnts=str2num(Header(commas(2):i-1));
%    end
%    if Header(i:i+7)=='channels';
%        EEG.nbchan=str2num(Header(commas(3):i-1));
%    end
%    if Header(i:i+11)=='=SampsPerSec';
%        EEG.srate=str2num(Header(commas(3+EEG.nbchan+5):i-1));
%    end
%    if Header(i:i+11)=='=#prestimPts';
%        EEG.event.latency=str2num(Header(commas(3+EEG.nbchan+6):i-1));
%        EEG.PreStimPts=EEG.event.latency;
%        EEG.event.type='lock';
%        EEG.epoch.eventlatency=EEG.event.latency;
%        EEG.xmin=0;
%        EEG.xmax=(EEG.pnts-1)*(1/EEG.srate);
%        EEG.times=EEG.xmin*1000:1000/EEG.srate:EEG.xmax*1000;
%    end
%end
%for ii=1:EEG.nbchan;
%    EEG.chanlocs(ii).labels=char(Header(commas(3+ii)+1:commas(3+ii+1)-1));
%end
%EEG.trials=1;    

%TempERPData=str2num(char(FileDouble(CRs(1)+1:length(FileDouble))'));
%TempERPData=reshape(TempERPData',EEG.pnts,EEG.nbchan);

%EEG.data=TempERPData';

%EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);