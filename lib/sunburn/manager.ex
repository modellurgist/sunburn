defmodule Sunburn.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  alias Sunburn.Components

  def setup do
    # Seed persistent components only for the first server start
    # (This will not be run on subsequent app restarts)
    :ok
  end

  @site_locations [
    %{zip_5: 46383, city: "Valparaiso", state: "IN", latitude: 41.45, longitude: -87.10}
  ]

  def startup do
    simulation_uuid = Ecto.UUID.generate()
    Components.SimulationTickCount.add(simulation_uuid, 0)

    # Load ephemeral components during first server start and again
    # on every subsequent app restart

    company_uuid = Ecto.UUID.generate()

    # Aggregated values

    # - Instantaneous
    Components.CompanyTotalDeliveredPower.add(company_uuid, 0.0)
    Components.CompanyMaximumPower.add(company_uuid, 0.0)
    Components.CompanyTotalDeliveredPowerEfficiency.add(company_uuid, 0.0)

    # Comparative values over time
    Components.CompanyChangeInTotalDeliveredPower.add(company_uuid, 0.0)

    # - Rolling 30-day (TODO)

    for site_id <- 1..1 do
      site_uuid = Ecto.UUID.generate()

      Components.SiteCompany.add(site_uuid, company_uuid)

      # Aggregated values
      Components.SiteTotalDeliveredPower.add(site_uuid, 0.0)
      Components.SiteMaximumPower.add(site_uuid, 0.0)

      site = Enum.at(@site_locations, site_id - 1)

      # Create site components

      # * Fixed attributes
      Components.SiteCity.add(site_uuid, site.city)
      Components.SiteState.add(site_uuid, site.state)
      Components.SiteZipCode.add(site_uuid, site.zip_5)
      Components.SiteLatitude.add(site_uuid, site.latitude)
      Components.SiteLongitude.add(site_uuid, site.longitude)
      # - panels (via search of ... for this site)

      # - hardware/transmission:
      #   - ... TODO

      # * Variable attributes
      #   - local time
      #   - sun up/down **
      #   - sun position
      #   - solar radiation (insolation)
      #     (insolation, in kW*h/m2 per day, where panels
      #      are rated in Watts at 1.0 kW/m2 of insolation)
      Components.SiteSolarRadiationPerDay.add(site_uuid, 3.94)

      # * aggregated values from its panels' components
      # Site.Components.SunUp.add(site_uuid, true)

      for _solar_panel_id <- 1..15 do
        panel_uuid = Ecto.UUID.generate()

        # Create panel components

        # - Site
        Components.PanelSite.add(panel_uuid, site_uuid)

        # - Performance specs:

        # Power Capacity (in kiloWatts, technically per 1.0 kW/m2 of insolation)
        Components.PanelPowerCapacity.add(panel_uuid, 0.35)

        # See https://pvwatts.nrel.gov/pvwatts.php for estimating power at location
        Components.PanelTotalDeliveredPower.add(panel_uuid, 0.0)

        # - hardware/transmission (TODO):
      end
    end

    :ok
  end

  # Declare all valid Component types
  def components do
    [
      Sunburn.Components.SimulationTickCount,
      Components.CompanyTotalDeliveredPowerEfficiency,
      Components.CompanyChangeInTotalDeliveredPower,
      Components.CompanyTotalDeliveredPower,
      Components.CompanyMaximumPower,
      Components.SiteCompany,
      Components.SiteZipCode,
      Components.SiteCity,
      Components.SiteState,
      Components.SiteLatitude,
      Components.SiteLongitude,
      Components.SiteTotalDeliveredPower,
      Components.SiteSolarRadiationPerDay,
      Components.SiteMaximumPower,
      Components.PanelSite,
      Components.PanelPowerCapacity,
      Components.PanelTotalDeliveredPower
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      Sunburn.Systems.DaySampler
    ]
  end
end
