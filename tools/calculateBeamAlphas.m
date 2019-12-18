function  [z0, dzdan, dzdam]= calculateBeamAlphas(an, am, section)
    switch section
        case 'hollowSquare'
            b = 0.9;
            dzdan = (0.3592*((am + an)^(1/2) - (am*b^2 + an)^(1/2)))/(1 - b^2)^1.5000;
            dzdam = (0.3592*((am + an)^(1/2) - b^2*(am*b^2 + an)^(1/2)))/(1 - b^2)^1.5000;
            z0 =  - (0.2394*((am*b^2 + an)^1.5000 - (am + an)^1.5000))/(1 - b^2)^1.5000 - (0.3592*am*((am + an)^(1/2) - b^2*(am*b^2 + an)^(1/2)))/(1 - b^2)^1.5000 - (0.3592*an*((am + an)^(1/2) - (am*b^2 + an)^(1/2)))/(1 - b^2)^1.5000;
    end      
end

