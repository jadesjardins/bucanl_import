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

function EEG = ImportERPscoreFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportERPscoreFormat;
	return;
end;	

% Perform FFT on EEG dataset channels "fftChs".
% Handle_FFTfig=figure;

eval(['fidIEF=fopen(''' FilePath FileName ''',''r'');']);

FileDouble=fread(fidIEF,'char');

CRs=find(FileDouble==10);
Header=char(FileDouble(1:CRs(1)-1)');

commas=find(Header==',');

for i=1:length(Header)-20;
    if Header(i:i+13)=='files_averaged';
        EEG.NTrialsUsed=str2num(Header(commas(1):i-1));
    end
    if Header(i:i+5)=='trials';
        EEG.NTrialsUsed=str2num(Header(commas(1):i-1));
    end
    
    if Header(i:i+11)=='NptsPerEpoch';
        EEG.pnts=str2num(Header(commas(2):i-1));
    end
    if Header(i:i+7)=='channels';
        EEG.nbchan=str2num(Header(commas(3):i-1));
    end
    if Header(i:i+11)=='=SampsPerSec';
        EEG.srate=str2num(Header(commas(3+EEG.nbchan+5):i-1));
    end
    if Header(i:i+11)=='=#prestimPts';
        EEG.event.latency=str2num(Header(commas(3+EEG.nbchan+6):i-1));
        EEG.PreStimPts=EEG.event.latency;
        EEG.event.type='lock';
        EEG.epoch.eventlatency=EEG.event.latency;
        EEG.xmin=0;
        EEG.xmax=(EEG.pnts-1)*(1/EEG.srate);
        EEG.times=EEG.xmin*1000:1000/EEG.srate:EEG.xmax*1000;
    end
end
for ii=1:EEG.nbchan;
    EEG.chanlocs(ii).labels=char(Header(commas(3+ii)+1:commas(3+ii+1)-1));
end
EEG.trials=1;    

TempERPData=str2num(char(FileDouble(CRs(1)+1:length(FileDouble))'));
TempERPData=reshape(TempERPData',EEG.pnts,EEG.nbchan);

EEG.data=TempERPData';

EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);