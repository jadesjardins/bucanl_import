% ImportBVARawFormat() - Import Raw data exported from Brain Vision Analyzer.
%
% Usage:
%   >>  EEG = ImportBVARawFormat( EEG, FileName, FilePath );
% Inputs:
%   EEG     - EEG dataset.
%    
% Outputs:
%   EEG     - EEG dataset.
%
% See also: 
%   pop_ImportBVARawFormat, EEGLAB 

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

function EEG = ImportBVARawFormat(EEG, FileName, FilePath);

if nargin < 1
	help ImportBVARawFormat;
	return;
end;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ HEADER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileName
if FileName(length(FileName)-3:length(FileName))=='vhdr';

    eval(['fidIBVAhdr=fopen(''' FilePath FileName ''',''r'');']);
    EEG.hdr=fread(fidIBVAhdr,'char');
    EEG.hdr=char(EEG.hdr');
    
    j=0;
    for i=1:length(EEG.hdr);
        if double(EEG.hdr(i))==13;
            j=j+1;
            CRs(j)=i;
        end
    end
    for i=1:length(CRs)-2;
        if EEG.hdr(CRs(i)+2:CRs(i)+10)=='DataFile=';
            EEG.DataFile=EEG.hdr(CRs(i)+11:(CRs(i+1)-1));
            break
        end
    end
    for i=1:length(CRs)-2;
        if EEG.hdr(CRs(i)+2:CRs(i)+12)=='DataPoints=';
            EEG.pnts=str2num(EEG.hdr(CRs(i)+13:(CRs(i+1)-1)));
            break
        end
    end
    for i=1:length(CRs)-2;
        if EEG.hdr(CRs(i)+2:CRs(i)+18)=='NumberOfChannels=';
            EEG.nbchan=str2num(EEG.hdr(CRs(i)+19:(CRs(i+1)-1)));
            break
        end
    end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eval(['fidIBVAraw=fopen(''' FilePath EEG.DataFile ''',''r'');'])

% Allocate memory (essential!)
EEG.data = zeros(EEG.nbchan, EEG.pnts, 'single');

EEG.data=fread(fidIBVAraw,'int16')
