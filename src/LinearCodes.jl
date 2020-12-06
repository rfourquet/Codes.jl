"""
    generator_matrix(c::Code)

Return the generator matrix of code `c`.
"""
function generator_matrix end

# default fallback
base_field(c::LinearCode) = c.field

# based on generator matrix
struct GeneratorCode{F,M<:MatrixElem} <: LinearCode{F}
    field::F
    genmat::M
end

generator_matrix(c::GeneratorCode) = c.genmat

blocklength(c::GeneratorCode) = ncols(generator_matrix(c))
dimension(c::GeneratorCode) = nrows(generator_matrix(c))
