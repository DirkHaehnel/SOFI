%Copyright © 2012 Marcel Leutenegger et al, École Polytechnique Fédérale de Lausanne,
%Laboratoire d'Optique Biomédicale, BM 5.142, Station 17, 1015 Lausanne, Switzerland.
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%
%Balanced super-resolution optical fluctuation imaging (bSOFI).
%
%   sofiBalance
%      Balanced image from linear cumulant images.
%
%   sofiCumulants
%      Raw cross-cumulant images from image stack.
%
%   sofiFlatten
%      Flatten raw cumulants by PSF full width at half-maximum diameter.
%
%   sofiGrids
%      Initialize unique pixel grids for partial products in the image.
%
%   sofiLinearize
%      Deconvolve and denoise flat cumulants and linearize the brightness.
%
%   sofiParameters
%      Estimate emitter parameters from flat cumulants.
%
%   sofiPSFfwhm
%      Estimate PSF full width at half-maximum diameter.
%
%   statusbar
%      Status bar showing the progress and the elapsed time.
%
%Example:
%   Analyze an image sequence from a TIFF file.
%
%>> [sofi,grid]=sofiCumulants('Stack.tif');
%>> [sofi,fwhm]=sofiFlatten([],sofi,grid);
%>> [ratio,density,bright]=sofiParameters(sofi);
%>> sofi=sofiLinearize(sofi,fwhm);
%>> sofi=sofiBalance(sofi,ratio);
%
%See also:
%
%[1] S. Geissbuehler, N. L. Bocchio, C. Dellagiacoma, C. Berclaz, M. Leutenegger,
%    Theo Lasser, "Mapping molecular statistics with balanced super-resolution
%    optical fluctuation imaging (bSOFI)," Optical Nanoscopy 1:4 (2012).
%
help contents
