"""
    generator_matrix(c::Code)

Return the generator matrix of code `c`.
"""
function generator_matrix end

# default fallback
base_field(c::LinearCode) = c.field
