function theta = calculateCollisionWithAnotherCircle(x0,y0)
    theta1 = -2*atan((72400*y0*cos(1069/1250) - 46884000*sin(7679/10000) - 4344000*sin(1069/1250) + 781400*y0*cos(7679/10000) + 72400*x0*sin(1069/1250) + 781400*x0*sin(7679/10000) - (38400000000000*x0 - 12002043981336*sin(1069/1250)^2*sin(7679/10000)^2 + 2620880000*x0^2*sin(1069/1250)^2 + 305292980000*x0^2*sin(7679/10000)^2 + 2620880000*y0^2*sin(1069/1250)^2 + 305292980000*y0^2*sin(7679/10000)^2 - 200000000*x0^2*y0^2 + 316810816000000*cos(1069/1250)*cos(7679/10000) + 316810816000000*sin(1069/1250)*sin(7679/10000) - 86357248315064*cos(1069/1250)*cos(7679/10000)^3 - 741359938784*cos(1069/1250)^3*cos(7679/10000) - 314505600000*x0*cos(1069/1250)^2 - 36635157600000*x0*cos(7679/10000)^2 - 86357248315064*sin(1069/1250)*sin(7679/10000)^3 - 741359938784*sin(1069/1250)^3*sin(7679/10000) - 314505600000*x0*sin(1069/1250)^2 - 36635157600000*x0*sin(7679/10000)^2 + 24000000000*x0*y0^2 + 14676928000000*cos(1069/1250)^2 - 17172529936*cos(1069/1250)^4 + 1709640688000000*cos(7679/10000)^2 - 233009509093201*cos(7679/10000)^4 + 14676928000000*sin(1069/1250)^2 - 17172529936*sin(1069/1250)^4 + 1709640688000000*sin(7679/10000)^2 - 233009509093201*sin(7679/10000)^4 - 1760000000000*x0^2 + 24000000000*x0^3 - 100000000*x0^4 - 320000000000*y0^2 - 100000000*y0^4 - 12002043981336*cos(1069/1250)^2*cos(7679/10000)^2 - 34345059872*cos(1069/1250)^2*sin(1069/1250)^2 - 4000681327112*cos(1069/1250)^2*sin(7679/10000)^2 - 4000681327112*cos(7679/10000)^2*sin(1069/1250)^2 - 466019018186402*cos(7679/10000)^2*sin(7679/10000)^2 + 2620880000*x0^2*cos(1069/1250)^2 + 305292980000*x0^2*cos(7679/10000)^2 + 2620880000*y0^2*cos(1069/1250)^2 + 305292980000*y0^2*cos(7679/10000)^2 - 741359938784*cos(1069/1250)^2*sin(1069/1250)*sin(7679/10000) - 86357248315064*cos(7679/10000)^2*sin(1069/1250)*sin(7679/10000) + 56573360000*x0^2*sin(1069/1250)*sin(7679/10000) + 56573360000*y0^2*sin(1069/1250)*sin(7679/10000) - 6788803200000*x0*cos(1069/1250)*cos(7679/10000) - 6788803200000*x0*sin(1069/1250)*sin(7679/10000) - 741359938784*cos(1069/1250)*cos(7679/10000)*sin(1069/1250)^2 - 86357248315064*cos(1069/1250)*cos(7679/10000)*sin(7679/10000)^2 + 56573360000*x0^2*cos(1069/1250)*cos(7679/10000) + 56573360000*y0^2*cos(1069/1250)*cos(7679/10000) - 16002725308448*cos(1069/1250)*cos(7679/10000)*sin(1069/1250)*sin(7679/10000) - 256000000000000)^(1/2))/(4344000*cos(1069/1250) - 1200000*x0 + 46884000*cos(7679/10000) + 2828668*cos(1069/1250)*cos(7679/10000) - 72400*x0*cos(1069/1250) - 781400*x0*cos(7679/10000) + 2828668*sin(1069/1250)*sin(7679/10000) + 72400*y0*sin(1069/1250) + 781400*y0*sin(7679/10000) + 131044*cos(1069/1250)^2 + 15264649*cos(7679/10000)^2 + 131044*sin(1069/1250)^2 + 15264649*sin(7679/10000)^2 + 10000*x0^2 + 10000*y0^2 + 16000000));
    theta2 = -2*atan((72400*y0*cos(1069/1250) - 46884000*sin(7679/10000) - 4344000*sin(1069/1250) + 781400*y0*cos(7679/10000) + 72400*x0*sin(1069/1250) + 781400*x0*sin(7679/10000) + (38400000000000*x0 - 12002043981336*sin(1069/1250)^2*sin(7679/10000)^2 + 2620880000*x0^2*sin(1069/1250)^2 + 305292980000*x0^2*sin(7679/10000)^2 + 2620880000*y0^2*sin(1069/1250)^2 + 305292980000*y0^2*sin(7679/10000)^2 - 200000000*x0^2*y0^2 + 316810816000000*cos(1069/1250)*cos(7679/10000) + 316810816000000*sin(1069/1250)*sin(7679/10000) - 86357248315064*cos(1069/1250)*cos(7679/10000)^3 - 741359938784*cos(1069/1250)^3*cos(7679/10000) - 314505600000*x0*cos(1069/1250)^2 - 36635157600000*x0*cos(7679/10000)^2 - 86357248315064*sin(1069/1250)*sin(7679/10000)^3 - 741359938784*sin(1069/1250)^3*sin(7679/10000) - 314505600000*x0*sin(1069/1250)^2 - 36635157600000*x0*sin(7679/10000)^2 + 24000000000*x0*y0^2 + 14676928000000*cos(1069/1250)^2 - 17172529936*cos(1069/1250)^4 + 1709640688000000*cos(7679/10000)^2 - 233009509093201*cos(7679/10000)^4 + 14676928000000*sin(1069/1250)^2 - 17172529936*sin(1069/1250)^4 + 1709640688000000*sin(7679/10000)^2 - 233009509093201*sin(7679/10000)^4 - 1760000000000*x0^2 + 24000000000*x0^3 - 100000000*x0^4 - 320000000000*y0^2 - 100000000*y0^4 - 12002043981336*cos(1069/1250)^2*cos(7679/10000)^2 - 34345059872*cos(1069/1250)^2*sin(1069/1250)^2 - 4000681327112*cos(1069/1250)^2*sin(7679/10000)^2 - 4000681327112*cos(7679/10000)^2*sin(1069/1250)^2 - 466019018186402*cos(7679/10000)^2*sin(7679/10000)^2 + 2620880000*x0^2*cos(1069/1250)^2 + 305292980000*x0^2*cos(7679/10000)^2 + 2620880000*y0^2*cos(1069/1250)^2 + 305292980000*y0^2*cos(7679/10000)^2 - 741359938784*cos(1069/1250)^2*sin(1069/1250)*sin(7679/10000) - 86357248315064*cos(7679/10000)^2*sin(1069/1250)*sin(7679/10000) + 56573360000*x0^2*sin(1069/1250)*sin(7679/10000) + 56573360000*y0^2*sin(1069/1250)*sin(7679/10000) - 6788803200000*x0*cos(1069/1250)*cos(7679/10000) - 6788803200000*x0*sin(1069/1250)*sin(7679/10000) - 741359938784*cos(1069/1250)*cos(7679/10000)*sin(1069/1250)^2 - 86357248315064*cos(1069/1250)*cos(7679/10000)*sin(7679/10000)^2 + 56573360000*x0^2*cos(1069/1250)*cos(7679/10000) + 56573360000*y0^2*cos(1069/1250)*cos(7679/10000) - 16002725308448*cos(1069/1250)*cos(7679/10000)*sin(1069/1250)*sin(7679/10000) - 256000000000000)^(1/2))/(4344000*cos(1069/1250) - 1200000*x0 + 46884000*cos(7679/10000) + 2828668*cos(1069/1250)*cos(7679/10000) - 72400*x0*cos(1069/1250) - 781400*x0*cos(7679/10000) + 2828668*sin(1069/1250)*sin(7679/10000) + 72400*y0*sin(1069/1250) + 781400*y0*sin(7679/10000) + 131044*cos(1069/1250)^2 + 15264649*cos(7679/10000)^2 + 131044*sin(1069/1250)^2 + 15264649*sin(7679/10000)^2 + 10000*x0^2 + 10000*y0^2 + 16000000));
    theta = [theta1; theta2];
end

