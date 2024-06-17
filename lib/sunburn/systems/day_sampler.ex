defmodule Sunburn.Systems.DaySampler do
  @moduledoc """
  Documentation for DaySampler system.
  """
  @behaviour ECSx.System

  alias Sunburn.Components.{
    SimulationTickCount,
    CompanyTotalDeliveredPower,
    CompanyMaximumPower,
    CompanyChangeInTotalDeliveredPower,
    CompanyTotalDeliveredPowerEfficiency,
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
    # Update tick count
    increment_tick_count()

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

  defp increment_tick_count do
    {sim_uuid, previous_count} = previous_tick_count()
    new_count = previous_count + 1

    SimulationTickCount.update(sim_uuid, new_count)
  end

  defp previous_tick_count do
    [{sim_uuid, count}] = SimulationTickCount.get_all()
    {sim_uuid, count}
  end

  defp sample_panel(panel_uuid, site_radiation) do
    capacity_nominal = PanelPowerCapacity.get(panel_uuid, 0.0)
    capacity_actual = capacity_nominal * site_radiation

    random_loss = :rand.normal(4.0, 20.0) / 100
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
    previous_delivered_power =
      CompanyTotalDeliveredPower.get(company_uuid) |> Decimal.from_float()

    current_delivered_power =
      Enum.map(sites_data, & &1.delivered_power) |> Enum.sum() |> Decimal.from_float()

    delivered_power_change = Decimal.sub(current_delivered_power, previous_delivered_power)

    current_maximum_power =
      Enum.map(sites_data, & &1.maximum_power) |> Enum.sum() |> Decimal.from_float()

    delivered_power_efficiency =
      if Decimal.equal?(current_maximum_power, 0) do
        current_maximum_power
      else
        current_delivered_power
        |> Decimal.div(current_maximum_power)
        |> Decimal.mult(100)
      end

    data =
      %{
        maximum_power: current_maximum_power |> Decimal.round(2) |> Decimal.to_float(),
        delivered_power: current_delivered_power |> Decimal.round(2) |> Decimal.to_float(),
        delivered_power_change: delivered_power_change |> Decimal.round(2) |> Decimal.to_float(),
        delivered_power_efficiency: delivered_power_efficiency |> Decimal.round(2) |> Decimal.to_float()
      }

    CompanyTotalDeliveredPower.update(company_uuid, data.delivered_power)
    CompanyMaximumPower.update(company_uuid, data.maximum_power)
    CompanyChangeInTotalDeliveredPower.update(company_uuid, data.delivered_power_change)
    CompanyTotalDeliveredPowerEfficiency.update(company_uuid, data.delivered_power_efficiency)

    :ok
  end
end
