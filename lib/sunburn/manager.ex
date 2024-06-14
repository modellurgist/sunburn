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
    %{city: "Valparaiso", state: "IN", latitude: 41.45, longitude: -87.10}
  ]

  def startup do
    # Load ephemeral components during first server start and again
    # on every subsequent app restart

    company_uuid = Ecto.UUID.generate()
    # aggregate stats
    # - instantaneous
    # - rolling 30-day

    for site_id <- 1..1 do
      site_uuid = Ecto.UUID.generate()

      site = @site_locations[site_id - 1]

      # create site components - TODO
      # * fixed
      Components.SiteCity.add(site_uuid, site.city)
      Components.SiteState.add(site_uuid, site.state)
      Components.SiteLatitude.add(site_uuid, site.latitude)
      Components.SiteLongitude.add(site_uuid, site.longitude)
      # * variable
      #   - local time
      #   - sun up/down **
      #   - sun position
      # - panels (via search of ... for this site)
      # - aggregated values from its panels' components
      # - hardware/transmission:
      #   - ... TODO
      # Site.Components.SunUp.add(site_uuid, true)
      # (insolation, in kW*h/m2 per day, where panels are rated in Watts at 1.0 kW/m2 of insolation)
      Components.SiteSolarRadiationPerDay.add(site_uuid, 3.94)

      for solar_panel_id < 1..15 do
        panel_uuid = Ecto.UUID.generate()

        # See https://pvwatts.nrel.gov/pvwatts.php for estimating power at location

        # create panel components - TODO
        # - site **
        Components.PanelSite.add(panel_uuid, site_uuid)
        # - performance specs:
        #   - ... TODO
        # Power Capacity (in kiloWatts, technically per 1.0 kW/m2 of insolation)
        Components.PanelPowerCapacity.add(panel_uuid, 0.35)
        # - hardware/transmission:
        #   - ... TODO
      end
    end

    :ok
  end

  # Declare all valid Component types
  def components do
    [
      Components.SiteCity,
      Components.SiteState,
      Components.SiteLatitude,
      Components.SiteLongitude,
      Components.SiteSolarRadiationPerDay,
      Components.PanelSite,
      Components.PanelPowerCapacity
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      # MyApp.Systems.SampleSystem
    ]
  end
end
