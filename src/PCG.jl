## Code for PCG ALGORITHM #######################################################

mutable struct PCG
    state::UInt64
    inc::UInt64

    function PCG(init_state::UInt64 = UInt64(42), init_seq::UInt64 = UInt64(54))
        pcg = new(UInt64(0), UInt64((init_seq << 1 | 1))) 
        pcg_rand(pcg)
        pcg.state += init_state
        pcg_rand(pcg)
        pcg
    end
end


function pcg_rand(pcg::PCG)
    oldstate = pcg.state
    pcg.state = UInt64(oldstate * 6364136223846793005 + pcg.inc)
    xorshifted = UInt32(((oldstate >> UInt64(18)) ⊻ oldstate) >> UInt64(27) & typemax(UInt32))
    rot = oldstate >> UInt64(59)
    return UInt32((xorshifted >> rot) | (xorshifted << ((-rot) & UInt32(31))))
end

pcg_randf(pcg) = Float32(pcg_rand(pcg)/typemax(UInt32))