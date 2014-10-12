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

function EEG = ImportInstCFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportInstCFormat;
	return;
end;	


eval(['fidIInstC=fopen(''' FilePath FileName ''',''r'');']);


% Read header information.

EEG.header=fread(fidIInstC,2048,'int16');

fseek(fidIInstC,185,'bof');
EEG.srate=fread(fidIInstC,25,'char');EEG.srate=char(EEG.srate(1:5))';EEG.srate=str2num(EEG.srate);

fseek(fidIInstC,330,'bof');
EEG.FootBundles=fread(fidIInstC,1,'long');
EEG.trials=1;

fseek(fidIInstC,1560,'bof');
foot=fread(fidIInstC,1,'long');

fseek(fidIInstC,1564,'bof');
EEG.nbchan=fread(fidIInstC,1,'int16');

fseek(fidIInstC,1566,'bof');
ChLabs=fread(fidIInstC,6*EEG.nbchan,'char');ChLabs=char(ChLabs)';

for i=1:EEG.nbchan;
    EEG.chanlocs(i).labels=deblank(ChLabs(i*6-5:i*6));
end

fseek(fidIInstC,foot,'bof');
EEG.footer=fread(fidIInstC,'int16');


% Create event structure.

j=0;
for i=0:192:192*(EEG.FootBundles-1);
    j=j+1;
    fseek(fidIInstC,foot+14+4+i,'bof');
    EEG.event(j).type=sprintf('%s%s', 'stm', num2str(fread(fidIInstC,1,'int16')));
    fseek(fidIInstC,foot+14+10+i,'bof');
    EEG.event(j).latency=round((floor((fread(fidIInstC,1,'long'))/EEG.nbchan+round(30/(1000/EEG.srate))))); % Instep event storage requires 30ms to be added to the latency of each event.
    fseek(fidIInstC,foot+14+20+i,'bof');
    EEG.event(j).rt=(fread(fidIInstC,1,'int16'));
    fseek(fidIInstC,foot+14+22+i,'bof');
    EEG.event(j).resp=(fread(fidIInstC,1,'int16'));
    
    EEG.event(j).code='';
    EEG.event(j).duration=0;
    EEG.event(j).channel=0;
    EEG.event(j).bvtime=[];
    EEG.event(j).urevent=j;
    EEG.event(j).code='';
    
    if EEG.trials==1;
        EEG.event(j).epoch=1;
    end
    
    % Add response event if response was made.
    if EEG.event(j).rt>0;
        j=j+1;
        EEG.event(j).type=sprintf('%s%s', 'rsp', char(EEG.event(j-1).resp));
        EEG.event(j).latency=round(EEG.event(j-1).latency+(EEG.event(j-1).rt/(1000/EEG.srate)-round(30/(1000/EEG.srate)))); % note 30ms correction again.

        EEG.event(j).code='';
        EEG.event(j).duration=0;
        EEG.event(j).channel=0;
        EEG.event(j).bvtime=[];
        EEG.event(j).urevent=j;
        EEG.event(j).code='';
        
        if EEG.trials==1;
            EEG.event(j).epoch=1;
        end
                    
    end

end


% Create data field.

fseek(fidIInstC,4096,'bof');
data=[];
data=fread(fidIInstC,(foot-4096)/2,'int16');

for i=1:EEG.nbchan;
    EEG.data(i,:)=data(i:EEG.nbchan:end).*0.48828125;
end

EEG.pnts=length(EEG.data(1,:));

EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);