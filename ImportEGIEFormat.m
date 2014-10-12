% ImportEGIEFormat() - Import EGI event export file.
%
% Usage:
%   >>  EEG = ImportEGIEFormat( EEG, FileName, FilePath );
% Inputs:
%   EEG     - EEG dataset.
%    
% Outputs:
%   EEG     - EEG dataset.
%
% See also: 
%   pop_ImportEGIEFormat, EEGLAB 

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

function EEG = ImportEGIEFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportEGIEFormat;
	return;
end;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ HEADER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(FileName)

eval(['fidEGIE=fopen(''' FilePath FileName ''',''r'');']);
EEG.EventFileStr=fread(fidEGIE,'char');
EEG.EventFileStr=char(EEG.EventFileStr');

EEG.data=0;

j=0;
for i=1:length(EEG.EventFileStr);
    if double(EEG.EventFileStr(i))==10;
        j=j+1;
        CRs(j)=i;
    end
end
for i=1:length(CRs)-3;
    EEG.event(i).label=EEG.EventFileStr(CRs(i+2)+1:CRs(i+2)+4);
    for ii=CRs(i+2):CRs(i+3);
        if EEG.EventFileStr(ii)=='_';
            HourMrk=ii;
            for iii=ii+1:CRs(i+3);
                if EEG.EventFileStr(iii)==':';
                    MinuteMrk=iii;
                    for iiii=iii+1:CRs(i+3);
                        if EEG.EventFileStr(iiii)==':';
                            SecondMrk=iiii;
                            for iiiii=iiii+1    :CRs(i+3);
                                if EEG.EventFileStr(iiiii)=='.';
                                    MillisecondMrk=iiiii;
                                    break
                                end
                            end
                            break
                        end
                    end
                    break
                end
            end
            break
        end
    end
    EEG.event(i).time(1)=0;
    EEG.event(i).time(2)=0;
    EEG.event(i).time(3)=0;
    EEG.event(i).time(4)=str2num(EEG.EventFileStr(HourMrk+1:MinuteMrk-1));
    EEG.event(i).time(5)=str2num(EEG.EventFileStr(MinuteMrk+1:SecondMrk-1));
    EEG.event(i).time(6)=str2num(EEG.EventFileStr(SecondMrk+1:MillisecondMrk+3));
end

EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);