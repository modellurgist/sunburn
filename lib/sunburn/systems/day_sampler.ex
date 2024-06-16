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
          site_radiation = SiteSolarRadiationPerDay.get(site_uuid)

          # over all panels for site, collect panel data
          panels_data =
            for panel_uuid <- PanelSite.search(site_uuid) do
              sample_panel(panel_uuid, site_radiation)
            end

          # update aggregated values for site
          aggregate_panels_for_site(site_uuid, panels_data)
        end

      # update aggregated values for company
      :ok = aggregate_sites_for_company(company_uuid, sites_data)
    end

    :ok
  end

  defp sample_panel(panel_uuid, site_radiation) do
    capacity_nominal = PanelPowerCapacity.get(panel_uuid, 0.0)
    capacity_actual = capacity_nominal * site_radiation

    random_loss = :rand.normal(4.0, 3.5)
    panel_losses = if random_loss > 0.0, do: random_loss, else: 0.0

    delivered_actual = capacity_actual * (1.0 - panel_losses)

    PanelTotalDeliveredPower.update(panel_uuid, delivered_actual)

    %{
      capacity_actual: capacity_actual,
      delivered_actual: delivered_actual
    }
  end

  defp aggregate_panels_for_site(site_uuid, panels_data) when is_list(panels_data) do
    maximum_power = Enum.map(panels_data, & &1.capacity_actual) |> Enum.sum()
    SiteMaximumPower.update(site_uuid, maximum_power)

    delivered_power = Enum.map(panels_data, & &1.delivered_actual) |> Enum.sum()
    SiteTotalDeliveredPower.update(site_uuid, delivered_power)

    %{
      maximum_power: maximum_power,
      delivered_power: delivered_power
    }
  end

  defp aggregate_sites_for_company(company_uuid, sites_data) do
    previous_delivered_power = CompanyTotalDeliveredPower.get(company_uuid) |> Decimal.from_float()
    previous_maximum_power = CompanyMaximumPower.get(company_uuid) |> Decimal.from_float()

    current_delivered_power = Enum.map(sites_data, & &1.delivered_power) |> Enum.sum() |> Decimal.from_float()

    current_maximum_power = Enum.map(sites_data, & &1.maximum_power) |> Enum.sum() |> Decimal.from_float()

    denominator = Decimal.sub(current_maximum_power, previous_maximum_power)

    delivered_power_change_percent =
      if Decimal.equal?(denominator, 0) do
        denominator
      else
        Decimal.div(
          Decimal.sub(current_delivered_power, previous_delivered_power),
          denominator
        )
        |> Decimal.round(2)
      end


    data =
      %{
        maximum_power: current_maximum_power |> Decimal.to_float(),
        delivered_power: current_delivered_power |> Decimal.to_float(),
        delivered_power_change: delivered_power_change_percent |> Decimal.to_float()
      }

    CompanyTotalDeliveredPower.update(company_uuid, data.delivered_power)
    CompanyMaximumPower.update(company_uuid, data.maximum_power)
    CompanyChangeInTotalDeliveredPower.update(company_uuid, data.delivered_power_change)

    :ok
  end
end
