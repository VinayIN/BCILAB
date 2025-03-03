% promax() - perform Promax oblique rotation after orthogonal Varimax 
%            rotation of the rows of the input data. A method for 
%            linear decomposition by "rotating to simple structure."
% Usage:
%        >> [R]   = promax(data,ncomps);
%        >> [R,V] = promax(data,ncomps,maxit);
%
% Inputs:
%     data    - Promax operates on rows of the input data matrix
%     ncomps  - operate on the N largest PCA components (default|0 -> all)
%     maxit   - maximum number of iterations {default|0 -> 5}
%
% Outputs:
%     R       - is the non-orthogonal Promax rotation matrix 
%                 i.e.,  >> promax_rotated_data = R*data;
%     V       - is the orthogonal Varimax rotation matrix 
%                 i.e.,  >> varimax_rotated_data = V*data;
%
% Author: Colin Humphries, CNL / Salk Institute, 1998
%
% See also: runica()

% Copyright (C) Colin Humphries, CNL / Salk Institute, June 1998
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

% formatted and modified to return V by Scott Makeig, 6/23/98
% reset maxit default to 5, added ncomps -sm 7/8/98
% 01-25-02 reformated help & license, added links -ad 
%
% Reference: 
%
% Hendrickson AE and White PO (1964) Promax: A quick method for rotation 
% to oblique simple structure, Br J of Stat Psych, X:xxx-xxx.

function [R,V] = promax(data,ncomps,maxit)

v = version;
indp = find(v == '.');
v = str2num(v(1:indp(2)-1));
if v >= 8.1
    disp('Note: for some unknown reason, this function does not return')
    disp('      NaN for a singular matrix under Matlab 2013a and later versions.')
    disp('      Promax on other matrices seems to as in previous revisions though.');
end;
    
DEFAULT_POWER     = 4;
DEFAULT_TOLERANCE = 1e-5;
MAX_ITERATIONS    = 5;
NEAR_ZERO         = 1e-8;

powr = DEFAULT_POWER; 
tol = DEFAULT_TOLERANCE;

if nargin < 1
  help promax
  return
end
if isempty(data)
  help promax
  return
end

if nargin < 2
   ncomps = 0;
end
chans = size(data,1)
if ncomps == 0
   ncomps = chans
end
if ncomps > chans
    error(sprintf('promax(): components must be <= number of data rows (%d).\n',chans));
end
if nargin < 3
  maxit = 0;
end
if maxit == 0
  maxit = MAX_ITERATIONS;
end

if ncomps < chans
  [eigenvectors,eigenvalues,compressed,datamean] = pcsquash(data,ncomps);
  data = compressed;
  clear compressed;
  eigenvectors = eigenvectors(:,1:ncomps); % make non-square
  eigenwts = pinv(eigenvectors); % find forward (non-square) weight matrix
end

R = varimax(data); % run Varimax on the (projected) data
B = R*data;        % compute rotated data
V = R;             % save Varimax matrix as V
if ncomps < chans
 V = V*eigenwts;   % include PCA reduction matrix
end
B = B';            % transpose
R = R';
cont = 1;
fprintf(...
  'Finding oblique Promax rotation using exponent %g and tolerance %g\n',...
                                                  powr,tol)
it = 1;
Pz = zeros(size(B));
while cont & it <= maxit
  P = Pz;
  ii = find(abs(B) > NEAR_ZERO); % avoid division by 0
  P(ii) = (abs(B(ii).^(powr+1)))./B(ii);
  tmp = inv(B'*B)*B'*P;
  tmp = normalcol(tmp);
  Rn = R*tmp;
  B = B*tmp;
  distnew = dot(Rn(:),R(:));
  if it > 1
    delta = abs(distnew-distold);
    if delta < tol
      cont = 0;
    end
    fprintf('#%d delta %f\n',it,delta)
    if isnan(delta)
      cont = 0;
    end
  end
  R = Rn;
  distold = distnew;
  it = it+1;
end
B = B';
R = R';
if ncomps < chans
   R = R*eigenwts; % include the pcsquash() compression
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function n=normalcol(m)

if isempty(m)
  fprintf('normalcol() has empty input!\n');
  return
end
[mr,mc] = size(m);
n = sqrt(ones./sum(m.*m));
n = ones(mr,1)*n;
n = n.*m;
