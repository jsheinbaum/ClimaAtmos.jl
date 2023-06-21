#####
##### EDMF SGS flux
#####

edmfx_sgs_flux_tendency!(Yₜ, Y, p, t, colidx, turbconv_model) = nothing

function edmfx_sgs_flux_tendency!(Yₜ, Y, p, t, colidx, turbconv_model::EDMFX)

    n = n_mass_flux_subdomains(turbconv_model)
    (; params, edmfx_upwinding) = p
    (; ᶠu³, ᶜh_tot, ᶜspecific) = p
    (; ᶠu³ʲs, ᶜh_totʲs, ᶜspecificʲs) = p
    (; ᶜρa⁰, ᶠu³⁰, ᶜspecific⁰, ᶜts⁰) = p
    (; dt) = p.simulation
    ᶜJ = Fields.local_geometry_field(Y.c).J

    thermo_params = CAP.thermodynamics_params(params)
    if p.atmos.edmfx_sgs_flux
        ᶠu³_diff_colidx = p.ᶠtemp_CT3[colidx]
        ᶜh_tot_diff_colidx = ᶜq_tot_diff_colidx = p.ᶜtemp_scalar[colidx]
        for j in 1:n
            @. ᶠu³_diff_colidx = ᶠu³ʲs.:($$j)[colidx] - ᶠu³[colidx]
            @. ᶜh_tot_diff_colidx = ᶜh_totʲs.:($$j)[colidx] - ᶜh_tot[colidx]
            vertical_transport!(
                Yₜ.c.ρe_tot[colidx],
                ᶜJ[colidx],
                Y.c.sgsʲs.:($j).ρa[colidx],
                ᶠu³_diff_colidx,
                ᶜh_tot_diff_colidx,
                dt,
                edmfx_upwinding,
            )
        end
        @. ᶠu³_diff_colidx = ᶠu³⁰[colidx] - ᶠu³[colidx]
        @. ᶜh_tot_diff_colidx =
            TD.total_specific_enthalpy.(
                thermo_params,
                ᶜts⁰[colidx],
                ᶜspecific⁰.e_tot[colidx],
            ) - ᶜh_tot[colidx]
        vertical_transport!(
            Yₜ.c.ρe_tot[colidx],
            ᶜJ[colidx],
            ᶜρa⁰[colidx],
            ᶠu³_diff_colidx,
            ᶜh_tot_diff_colidx,
            dt,
            edmfx_upwinding,
        )

        if !(p.atmos.moisture_model isa DryModel)
            for j in 1:n
                @. ᶠu³_diff_colidx = ᶠu³ʲs.:($$j)[colidx] - ᶠu³[colidx]
                @. ᶜq_tot_diff_colidx =
                    ᶜspecificʲs.:($$j).q_tot[colidx] - ᶜspecific.q_tot[colidx]
                vertical_transport!(
                    Yₜ.c.ρq_tot[colidx],
                    ᶜJ[colidx],
                    Y.c.sgsʲs.:($j).ρa[colidx],
                    ᶠu³_diff_colidx,
                    ᶜq_tot_diff_colidx,
                    dt,
                    edmfx_upwinding,
                )
            end
            @. ᶠu³_diff_colidx = ᶠu³⁰[colidx] - ᶠu³[colidx]
            @. ᶜq_tot_diff_colidx =
                ᶜspecific⁰.q_tot[colidx] - ᶜspecific.q_tot[colidx]
            vertical_transport!(
                Yₜ.c.ρq_tot[colidx],
                ᶜJ[colidx],
                ᶜρa⁰[colidx],
                ᶠu³_diff_colidx,
                ᶜq_tot_diff_colidx,
                dt,
                edmfx_upwinding,
            )
        end
    end

    # TODO: Add momentum flux

    # TODO: Add tracer flux

    return nothing
end

function edmfx_sgs_flux_tendency!(
    Yₜ,
    Y,
    p,
    t,
    colidx,
    turbconv_model::DiagnosticEDMFX,
)

    n = n_mass_flux_subdomains(turbconv_model)
    (; edmfx_upwinding) = p
    (; ᶠu³, ᶜh_tot, ᶜspecific) = p
    (; ᶜρaʲs, ᶠu³ʲs, ᶜh_totʲs, ᶜq_totʲs) = p
    (; dt) = p.simulation
    ᶜJ = Fields.local_geometry_field(Y.c).J

    if p.atmos.edmfx_sgs_flux
        ᶠu³_diff_colidx = p.ᶠtemp_CT3[colidx]
        ᶜh_tot_diff_colidx = ᶜq_tot_diff_colidx = p.ᶜtemp_scalar[colidx]
        for j in 1:n
            @. ᶠu³_diff_colidx = ᶠu³ʲs.:($$j)[colidx] - ᶠu³[colidx]
            @. ᶜh_tot_diff_colidx = ᶜh_totʲs.:($$j)[colidx] - ᶜh_tot[colidx]
            vertical_transport!(
                Yₜ.c.ρe_tot[colidx],
                ᶜJ[colidx],
                ᶜρaʲs.:($j)[colidx],
                ᶠu³_diff_colidx,
                ᶜh_tot_diff_colidx,
                dt,
                edmfx_upwinding,
            )
        end

        if !(p.atmos.moisture_model isa DryModel)
            for j in 1:n
                @. ᶠu³_diff_colidx = ᶠu³ʲs.:($$j)[colidx] - ᶠu³[colidx]
                @. ᶜq_tot_diff_colidx =
                    ᶜq_totʲs.:($$j)[colidx] - ᶜspecific.q_tot[colidx]
                vertical_transport!(
                    Yₜ.c.ρq_tot[colidx],
                    ᶜJ[colidx],
                    ᶜρaʲs.:($j)[colidx],
                    ᶠu³_diff_colidx,
                    ᶜq_tot_diff_colidx,
                    dt,
                    edmfx_upwinding,
                )
            end
        end
    end

    # TODO: Add momentum flux

    # TODO: Add tracer flux

    return nothing
end
