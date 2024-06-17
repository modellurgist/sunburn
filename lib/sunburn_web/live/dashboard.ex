defmodule SunburnWeb.Dashboard do
  use SunburnWeb, :live_view

  alias SunburnWeb.StatsCard

  alias Sunburn.Components.{
    CompanyChangeInTotalDeliveredPower,
    CompanyTotalDeliveredPowerEfficiency
  }

  @resample_interval 50

  @impl true
  def mount(_params, _session, socket) do
    # values = [
    #   %{key: "0", leaf: true, label: "Item 0", data: %{name: "Item 0"}, children: []}
    # ]

    [{company_uuid, _efficiency}] = CompanyTotalDeliveredPowerEfficiency.get_all()

    socket =
      socket
      |> assign(:company_uuid, company_uuid)
      |> assign_resampled_company_stats()

    if connected?(socket) do
      send(self(), :first_sample)
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full grid grid-cols-11">
      <div class="col-start-5 col-span-3">
        <StatsCard.component
          headline="Power Delivery Efficiency"
          status={@delivered_power_status}
          value={@delivered_power_efficiency}
          value_units="%"
          change_direction={@delivered_power_change_direction}
          change_value={@delivered_power_change}
          change_units="kWh/day"
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(:first_sample, socket) do
    # :ok = wait_for_spawn(socket.assigns.player_entity)

    # socket =
    #   socket
    #   |> assign(loading: false)

    :timer.send_interval(@resample_interval, :resample)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:resample, socket) do
    {:noreply, assign_resampled_company_stats(socket)}
  end

  defp assign_resampled_company_stats(socket) do
    company_uuid = socket.assigns.company_uuid

    power_efficiency = CompanyTotalDeliveredPowerEfficiency.get(company_uuid)
    power_change = CompanyChangeInTotalDeliveredPower.get(company_uuid)
    power_change_direction = if power_change >= 0, do: :positive, else: :negative

    delivered_power_status = if power_efficiency >= 98.5, do: :good, else: :bad

    socket
    |> assign(:delivered_power_status, delivered_power_status)
    |> assign(:delivered_power_efficiency, power_efficiency)
    |> assign(:delivered_power_change, power_change)
    |> assign(:delivered_power_change_direction, power_change_direction)
  end
end
