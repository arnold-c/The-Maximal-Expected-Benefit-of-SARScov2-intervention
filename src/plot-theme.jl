using CairoMakie

function theme_adjustments()
    return Theme(;
        fontsize = 28,
        Axis = (;
            xlabelsize = 28,
            ylabelsize = 28,
            xlabelfont = :bold,
            ylabelfont = :bold,
        ),
        Colorbar = (;
            labelsize = 28,
            labelfont = :bold,
        ),
    )
end
custom_theme = merge(theme_adjustments(), theme_minimal())

set_theme!(
    custom_theme;
    linewidth = 6,
)

update_theme!(; size = (1300, 800))
