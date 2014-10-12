% ImportBVAMarkerFormat() - Read BVA marker export file.
%
% Usage:
%   >>  EEG = ImportBVAMarkerFormat( EEG, FileName, FilePath );
% Inputs:
%   EEG         - EEG dataset.
%   FileName    - Name of input file.
%   PathName    - Path of input file.
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

function EEG = ImportBVAMarkerFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportBVAMarkerFormat;
	return;
end;	

% Read input file in character format;

eval(['fidIBVAmF=fopen(''' FilePath FileName ''',''r'');']);

if is emprty(EEG.data)
    EEG.data=[1 2 3];
end

TEMPmrkfile=[];
TEMPmrkfile=fread(fidIBVAmF,'char');
EEG.mrkfile=[];
EEG.mrkfile=char(TEMPmrkfile)';
break
EEG.srate=[];
e=0;
for i=1:length(EEG.mrkfile)-25;
    if EEG.mrkfile(i:i+13)=='Sampling rate:'
        for ii=1:20;
            if EEG.mrkfile(i+13+ii:i+13+ii+2)=='Hz,';
                EEG.srate=str2num(EEG.mrkfile(i+14:i+13+ii-1));
                break
            end
        end
    end
    %EEG.event=[];
    if EEG.mrkfile(i:i+8)=='Stimulus,';
        e=e+1;
        for ii=1:20;
            if EEG.mrkfile(i+8+ii)==','
                EEG.event(e).type=EEG.mrkfile(i+9:i+8+ii-1);
                for iii=1:20;
                    if EEG.mrkfile(i+8+ii+iii)==',';
                        EEG.event(e).pos=str2num(EEG.mrkfile(i+8+ii+1:i+8+ii+iii-1));
                        EEG.event(e).latency=round(EEG.event(e).pos*(1000/EEG.srate));
                        break
                    end
                end
                break
            end
        end
    end 
end


EEG.CongC=[];
cc=0;
for i=2:length(EEG.event);
    if (EEG.event(i).type==' S 5' & EEG.event(i-1).type==' S 1') | (EEG.event(i).type==' S 6' & EEG.event(i-1).type==' S 2');
        cc=cc+1;
        EEG.CongC(cc)=EEG.event(i).latency-EEG.event(i-1).latency;
    end
end

EEG.IncC=[];
ic=0;
for i=2:length(EEG.event);
    if (EEG.event(i).type==' S 5' & EEG.event(i-1).type==' S 3') | (EEG.event(i).type==' S 6' & EEG.event(i-1).type==' S 4');
        ic=ic+1;
        EEG.IncC(ic)=EEG.event(i).latency-EEG.event(i-1).latency;
    end
end

EEG.CongE=[];
ce=0;
for i=2:length(EEG.event);
    if (EEG.event(i).type==' S 5' & EEG.event(i-1).type==' S 2') | (EEG.event(i).type==' S 6' & EEG.event(i-1).type==' S 1');
        ce=ce+1;
        EEG.CongE(ce)=EEG.event(i).latency-EEG.event(i-1).latency;
    end
end

EEG.IncE=[];
ie=0;
for i=2:length(EEG.event);
    if (EEG.event(i).type==' S 5' & EEG.event(i-1).type==' S 4') | (EEG.event(i).type==' S 6' & EEG.event(i-1).type==' S 5');
        ie=ie+1;
        EEG.IncE(ie)=EEG.event(i).latency-EEG.event(i-1).latency;
    end
end

EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);

