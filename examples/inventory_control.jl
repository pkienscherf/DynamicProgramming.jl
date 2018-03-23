#  Copyright 2018, Oscar Dowson
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#############################################################################

#=
    Example 1.3.2 from
        Bertskas, D. (2005). Dynamic Programming and Optimal Control:
        Volume I (3rd ed.). Bellmont, MA: Athena Scientific.
=#

using DynamicProgramming, Base.Test

m = SDPModel(
        stages = 3,
        sense  = :Min
            ) do sp, t

    @states!(sp, begin
        xₖ in 0:1:2
    end)

    @controls!(sp, begin
        uₖ in 0:1:2
    end)

    @noises!(sp, begin
        wₖ in DiscreteDistribution([0.0, 1.0, 2.0], [0.1, 0.7, 0.2])
    end)

    dynamics!(sp) do y, x, u, w
        y[xₖ] = max(0, x[xₖ] + u[uₖ] - w[wₖ])
        return u[uₖ] + (x[xₖ] + u[uₖ] - w[wₖ])^2
    end

    terminalobjective!(sp) do x
        return 0.0
    end

    constraints!(sp) do x, u, w
        x[xₖ] + u[uₖ] - w[wₖ] <= 2
    end

end

solve(m, realisation=HereAndNow)

bertsekas_solution = [
    3.7   2.5  1.3;
    2.7   1.5  0.3;
    2.828 1.68 1.1
]
for t in 1:3
    for xk in 0:1:2
        @test isapprox(m.stages[t].interpolatedsurface[xk], bertsekas_solution[xk+1, t], atol=1e-2)
    end
end
