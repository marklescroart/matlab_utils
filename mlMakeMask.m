function Mask = mlMakeMask(ImageMatrix)

% Usage: mlMakeMask(ImageMatrix)
% 
% Create a perfectly effective mask given a set of black and white images

BW = ImageMatrix; 

Mask = 128*ones(400,400);

MaskPos = max(BW,[],3);
MaskNeg = min(BW,[],3);

% Mask(MaskNeg<=127) = MaskNeg(MaskNeg<=127);
% Mask(MaskPos>=129) = MaskPos(MaskPos>=129);

% NOTE: if we loop this instead, we might be able to get more subtle mixing
% of the other images. As it is, the contrast comes out a little faint.
Odds = 1:2:numel(Mask);
Evens = 2:2:numel(Mask);
Mask(Odds) = MaskPos(Odds);
Mask(Evens) = MaskNeg(Evens);

Mask = uint8(Mask);  