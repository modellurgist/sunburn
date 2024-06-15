defmodule Sunburn.Systems.DaySampler do
  @moduledoc """
  Documentation for DaySampler system.
  """
  @behaviour ECSx.System

  alias Sunburn.Components.{
    CompanyTotalDeliveredPower,
    CompanyMaximumPower,
    CompanyChangeInTotalDeliveredPower,
    SiteCompany,
    # SiteZipCode,
    # SiteCity,
    # SiteState,
    # SiteLatitude,
    # SiteLongitude,
    SiteTotalDeliveredPower,
    SiteSolarRadiationPerDay,
    SiteMaximumPower,
    PanelSite,
    PanelPowerCapacity,
    PanelTotalDeliveredPower
  }

  @impl ECSx.System
  @doc "Triggered at each tick of simulation"
  def run do
    # over all companies, collect company data
    for {company_uuid, _power} <- CompanyTotalDeliveredPower.get_all() do

      # over all sites at company, collect site data
      sites_data =
        for site_uuid <- SiteCompany.search(company_uuid) do

          # over all panels for site, collect panel data
          panels_data =
            for panel_uuid <- PanelSite.search(site_uuid) do
              sample_panel(panel_uuid)
            end

          # update aggregated values for site
          aggregate_panels_for_site(site_uuid, panels_data)
        end

      # update aggregated values for company
      aggregate_sites_for_company(company_uuid, sites_data)
    end

    :ok
  end

  defp sample_panel(panel_uuid) do
    # PanelPowerCapacity,
    # PanelTotalDeliveredPower
  end

  defp aggregate_panels_for_site(site_uuid, panels_data) do
    # SiteTotalDeliveredPower,
    # SiteSolarRadiationPerDay,
    # SiteMaximumPower,
  end

  defp aggregate_sites_for_company(company_uuid, sites_data) do
    # CompanyTotalDeliveredPower,
    # CompanyMaximumPower,
    # CompanyChangeInTotalDeliveredPower,
  end
end
