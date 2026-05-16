*! litdi 0.2.0  12may2026
*! Convenience alias for litdiscover. Forwards every argument to
*! litdiscover and propagates returned scalars and macros back to the
*! caller. See `help litdiscover' for full documentation.
*!
*! Usage is identical to litdiscover. Any combination of options that
*! works with `litdiscover, ...` works the same with `litdi, ...`.

capture program drop litdi

program define litdi, rclass
    version 19.5

    litdiscover `0'
    return add
end
