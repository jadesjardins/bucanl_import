% ImportMULFormat() - Import BESA .mul file.
%
% Usage:
%   >>  EEG = ImportMULFormat( EEG, FileName, FilePath );
% Inputs:
%   EEG     - EEG dataset.
%    
% Outputs:
%   EEG     - EEG dataset.
%
% See also: 
%   EEGLAB 

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

function EEG = ImportMULFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportMULFormat;
	return;
end;	

eval(['fidIMULF=fopen(''' FilePath FileName ''',''r'');']);

FileDouble=fread(fidIMULF,'char');
CRs=find(FileDouble==13);

Header=char(FileDouble(1:CRs(1)-1)');
HSs=find(double(Header)==32);

for i=1:length(Header)-20;
    if Header(i:i+10)=='TimePoints=';
        for ii=1:length(HSs);
            if HSs(ii)>i;
                EEG.NTrialsUsed=str2num(Header(i+11:HSs(ii)));
                break
            end
        end
    end
    if Header(i:i+8)=='Channels=';
        for ii=1:length(HSs);
            if HSs(ii)>i;
                EEG.nbchan=str2num(Header(i+9:HSs(ii)));
                break
            end
        end
    end
    if Header(i:i+20)=='SamplingInterval[ms]=';
        for ii=1:length(HSs);
            if HSs(ii)>i;
                EEG.srate=1000/(str2num(Header(i+21:HSs(ii))));
                break
            end
        end
    end
end


ChanStr=char(FileDouble(CRs(1)+1:CRs(2)-1));
CSs=find(double(ChanStr)==32);

for i=1:EEG.nbchan;
    if i<EEG.nbchan;
        EEG.chanlocs(i).labels=strtrim(char(ChanStr(CSs(i):CSs(i+1))'));
    else
        if length(CSs)>EEG.nbchan;
            EEG.chanlocs(i).labels=strtrim(char(ChanStr(CSs(i):CSs(i+1))'));
        else
            EEG.chanlocs(i).labels=strtrim(char(ChanStr(CSs(i):length(ChanStr))'));
        end
    end
end

EEG.trials=1;


TempData=str2num(char(FileDouble(CRs(2):length(FileDouble)))');
EEG.data=TempData';

EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);