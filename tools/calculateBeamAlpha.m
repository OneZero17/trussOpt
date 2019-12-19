function beamAlpha = calculateBeamAlpha(area, section)
    switch section
        case 'square'
            length = sqrt(area) / 1000;
            beamAlpha = length^3 /4;
        case 'hollowSquare'
            t = 0.1;
            length = sqrt(area/0.19) / 1000;
            beamAlpha = length^3 /4 - ((1-2*t)*length)^3/16;
    end
end

