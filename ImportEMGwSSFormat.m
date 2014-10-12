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

function EEG = ImportEMGwSSFormat(EEG, FilePath);

if nargin < 1
	help ImportEMGwSSFormat;
	return;
end;	
BSlash=find(FilePath=='\');

CurrentPath1=FilePath(1:BSlash(length(BSlash)));
CurrentPath2=FilePath(BSlash(length(BSlash))+1:length(FilePath));

GoToPathStr=sprintf('%s%s%s','cd ''', FilePath, '''');
eval([GoToPathStr]);

EEG.filepath=CurrentPath1;
EEG.filename=CurrentPath2;

EEG.comments=sprintf('%s %s', 'Original file:', CurrentPath2);
x=[];
x=x(3:length(x));

disp(x);

j=0;

if isfield(EEG, 'files')
    EEG=rmfield(EEG,'files');
end

for i=1:length(x);
    if x(i).name(length(x(i).name)-3:length(x(i).name))=='.emg';
        index=str2num(x(i).name(strfind(x(i).name,'[')+4:strfind(x(i).name,']')-1));
        j=j+1;
        EEG.files(index)=x(i);
    end
end
    
EEG.files.name

    EEG.data = [];
    
    % for each trial
    for j=1:length(EEG.files);
        % jj = Trial

%        ALLEEG(j).data = []; % Default value
        fId=fopen(EEG.files(j).name, 'r', 'n'); 
        if fId>0
           % Read in header information
           EEG.header.ID= fgets(fId,4);                                                         % File ID
           % Verify the file ID
           if EEG.header.ID == 'DEMG'
               fprintf(1, 'Reading file %s...\n',EEG.files(j).name);        
       
               EEG.header.Version = fread(fId,1,'uint16');                                      % File version
       
               % Read old file format

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

               if EEG.header.Version  == 1 | EEG.header.Version  == 2
                   EEG.header.FileType = 0;                                 % FileType (0 = RAW data)
                   EEG.header.EMGworksVersion = '';                         % EMGworks Version ("1.0.0.0")
                   EEG.header.DADLLversion = '';                            % DADLL Version ("1.0.0.0")
                   EEG.header.CardManufacturer = '';                        % A/D card Manufacturer
                   EEG.header.ADCardID = [];                                % A/D card Identifier
                   EEG.header.ESeries = [];                                  % National Instruments E-Series Card? (0 = NO, 1 = YES)
                   EEG.header.Channels = fread(fId,1,'unsigned short');     % Number of channels
                   EEG.header.Fs= fread(fId,1,'unsigned long');             % Actual sampling frequency
                   EEG.header.Samples = fread(fId,1,'unsigned long');       % Actual number of samples
                   EEG.header.SamplesDesired = [];                          % Desired number of samples
                   EEG.header.FsDesired = header.Fs;                        % Desired sampling frequency 
                   EEG.header.DataStart = [];                              % Data start point in the file (byte count)
                   EEG.header.TriggerStart = [];                             % Start Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
                   EEG.header.TriggerStop = [];                              % Stop Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
                   EEG.header.DaqSingleEnded = [];                           % Single ended Daq mode (1 = Single ended)
                   EEG.header.DaqBipolar = [];                               % Bipolar ended Daq mode (1 = Bipolar)
                   EEG.header.UseCamera = 0;                                % Camera use (0 = NO, 1 = YES)
                   %strLength = fread(fId,1,'uint32'); 
                   EEG.header.VideoFilename = '';                           % Associated Video File name
                   % Read in Channel info
                   for i = 1 : EEG.header.Channels
                       EEG.header.ChannelInfo(i).Channel = i;               % Channel number (one based) 
                       % strLength = fread(fId,1,'uint32'); 
                       EEG.header.ChannelInfo(i).Unit = '';                 % Unit
                       % strLength = fread(fId,1,'uint32'); 
                       EEG.header.ChannelInfo(i).Label = ['Ch' int2str(i)]; % Label
                       EEG.header.ChannelInfo(i).SystemGain = [];           % System Gain
                       EEG.header.ChannelInfo(i).ADGain = [];               % AD Gain
                       EEG.header.ChannelInfo(i).BitResolution = [];        % Bit resolution
                       EEG.header.ChannelInfo(i).Bias = [];                 % System Bias
                       EEG.header.ChannelInfo(i).HP = [];                   % High Pass cutoff frequency
                       EEG.header.ChannelInfo(i).LP = [];      
                   end%for i = 1 : header.Channels
                   % read the data
                   resolution=fread(fId,1,'char');%
                   EEG.xmin=fread(fId,1,'schar');%
                   %vMin=fread(fId,1,'schar');%
                   EEG.xmin=fread(fId,1,'schar');%
                   %vMax=fread(fId,1,'schar');%
                   switch EEG.header.Version
                       case 1	%data stored as floats
                           EEG.data(:,:,j)=fread(fId,[EEG.header.Channels,EEG.header.Samples],'float');	% read the emg matrix in
                       case 2	%data stored as uints
                           EEG.data(:,:,j)=fread(fId,[EEG.header.Channels,EEG.header.Samples],'uint16');	% read the emg matrix in
                           EEG.data(:,:,j)=(EEG.data(:,:,j)/(2^resolution-1)*(EEG.xmax-EEG.xmin) + EEG.xmin)*10000;			% scale the data	
                   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


               elseif EEG.header.Version == 3
                   % Read the rest of the header.
                   EEG.header.FileType = fread(fId,1,'uint32');                                 % FileType (0 = RAW data)
                   EEG.header.EMGworksVersion = char(fread(fId,11,'char'))';                    % EMGworks Version ("1.0.0.0")
                   EEG.header.DADLLversion = char(fread(fId,11,'char'))';                       % DADLL Version ("1.0.0.0")
                   EEG.header.CardManufacturer = char(fread(fId,255,'char'))';                  % A/D card Manufacturer
                   EEG.header.ADCardID = fread(fId,1,'uint32');                                 % A/D card Identifier
                   EEG.header.ESeries = fread(fId,1,'uint32');                                  % National Instruments E-Series Card? (0 = NO, 1 = YES)
                   EEG.nbchan = fread(fId,1,'uint32');                                 % Number of channels
        %           EEG.header.Channels = fread(fId,1,'uint32');                                 % Number of channels
                   EEG.pnts = fread(fId,1,'uint32');                                  % Actual number of samples
        %           EEG.header.Samples = fread(fId,1,'uint32');                                  % Actual number of samples
                   EEG.header.SamplesDesired = fread(fId,1,'uint32');                           % Desired number of samples
                   EEG.srate= fread(fId,1,'double');                                        % Actual sampling frequency
        %           EEG.header.Fs= fread(fId,1,'double');                                        % Actual sampling frequency
                   EEG.header.FsDesired = fread(fId,1,'double');                                % Desired sampling frequency 
                   EEG.header.DataStart = fread(fId,1,'uint32');                                % Data start point in the file (byte count)
                   EEG.header.TriggerStart = fread(fId,1,'uint32');                             % Start Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
                   EEG.header.TriggerStop = fread(fId,1,'uint32');                              % Stop Trigger mode (0 = Auto, 1 = Manual, 2 = External trigger)
                   EEG.header.DaqSingleEnded = fread(fId,1,'uint32');                           % Single ended Daq mode (1 = Single ended)
                   EEG.header.DaqBipolar = fread(fId,1,'uint32');                               % Bipolar ended Daq mode (1 = Bipolar)
                   EEG.header.UseCamera = fread(fId,1,'uint32');                                % Camera use (0 = NO, 1 = YES)
                   EEG.strLength = fread(fId,1,'uint32'); 
                   EEG.header.VideoFilename = char(fread(fId,EEG.strLength,'char'))';               % Associated Video File name
                   % Read in Channel info
                   for i = 1 : EEG.nbchan
                       EEG.header.ChannelInfo(i).Channel = fread(fId,1,'uint32');               % Channel number (one based) 
                       EEG.strLength = fread(fId,1,'uint32'); 
                       EEG.header.ChannelInfo(i).Unit = char(fread(fId,EEG.strLength,'char'))';     % Unit
                       EEG.strLength = fread(fId,1,'uint32'); 
                       EEG.chanlocs(i).labels = char(fread(fId,EEG.strLength,'char'))';    % Label
    %               EEG.header.ChannelInfo(i).Label = char(fread(fId,EEG.strLength,'char'))';    % Label
                       EEG.header.ChannelInfo(i).SystemGain = fread(fId,1,'double');            % System Gain
                       EEG.header.ChannelInfo(i).ADGain = fread(fId,1,'double');                % AD Gain
                       EEG.header.ChannelInfo(i).BitResolution = fread(fId,1,'double');         % Bit resolution
                       EEG.header.ChannelInfo(i).Bias = fread(fId,1,'double');                  % System Bias
                       EEG.header.ChannelInfo(i).HP = fread(fId,1,'double');                    % High Pass cutoff frequency
                       EEG.header.ChannelInfo(i).LP = fread(fId,1,'double');                    % Low Pass cutoff frequency
                   end    
                   % Read the data.
                   EEG.data(:,:,j) = fread(fId, [EEG.nbchan, EEG.pnts], 'int16');
           
                   % Scale the data
                   for i = 1 : EEG.nbchan
                       EEG.data(i,:,j) = ((EEG.data(i,:,j) / EEG.header.ChannelInfo(i).ADGain * 5 / 2^15 - EEG.header.ChannelInfo(i).Bias) /  EEG.header.ChannelInfo(i).SystemGain)*10000;  
                   end
               else
                   fprintf(1, 'Uknown file version for file %s\n',strcat(FilePath, FileName));
               end
           else %if header.ID == 'DEMG'
               fprintf(1, 'File %s is not a proper EMG file\n',strcat(FilePath, FileName));
               EEG.header=[];  % need to return something otherwise error message
               EEG.data = [];  
           end %if header.ID == 'DEMG'
           fclose(fId);
        else
            fprintf(1, 'File %s not found !!!\n',strcat(FilePath, FileName));
            EEG.header=[];  % need to return something otherwise error message
            EEG.data = [];
            catch_strings.new_and_hist
        end
    end
    EEG.pnts = size(EEG.data,2);
    EEG.trials = size(EEG.data,3);
    EEG.epoch = [];
    EEG.xmin = 0;
    EEG.xmax = (EEG.pnts-1)*(1000/EEG.srate);
    %EEG = ALLEEG(j);
    %EEG = eeg_checkset(EEG);
    %eeglab redraw;

%    cd ..
%end
    
return
 
        
    





