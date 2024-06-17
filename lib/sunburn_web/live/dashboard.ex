defmodule SunburnWeb.Dashboard do
  use SunburnWeb, :live_view

  alias SunburnWeb.StatsCard

  alias Sunburn.Components.{
    SimulationTickCount,
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
      |> assign(:simulation_started_at, Timex.now())
      |> assign(:company_uuid, company_uuid)
      |> resample()

    if connected?(socket) do
      send(self(), :first_sample)
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="text-center text-xl font-bold"><%= @current_simulation_datetime %></div>

    <div class="mt-4 w-full grid grid-cols-11">
      <div class="col-start-5 col-span-3">
        <StatsCard.component
          headline="Power Delivery Efficiency"
          status={@delivered_power_status}
          value={@delivered_power_efficiency}
          value_units="%"
          change_direction={@delivered_power_change_direction}
          change_value={@delivered_power_change}
          change_units="kWh/d"
        />
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(:first_sample, socket) do
    socket = resample(socket)
    :timer.send_interval(@resample_interval, :resample)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:resample, socket) do
    {:noreply, resample(socket)}
  end

  defp resample(socket) do
    socket
    |> assign_current_simulation_tick()
    |> assign_simulated_datetime()
    |> assign_resampled_company_stats()
  end

  defp assign_simulated_datetime(%{assigns: assigns} = socket) do
    formatted_datetime =
      assigns.simulation_started_at
      |> current_simulated_time(assigns.tick_count)
      |> format_date_simulated_time()

    assign(socket, :current_simulation_datetime, formatted_datetime)
  end

  defp assign_resampled_company_stats(socket) do
    company_uuid = socket.assigns.company_uuid

    power_efficiency = CompanyTotalDeliveredPowerEfficiency.get(company_uuid)
    power_change = CompanyChangeInTotalDeliveredPower.get(company_uuid)
    power_change_direction = if power_change >= 0, do: :positive, else: :negative

    delivered_power_status = if power_efficiency >= 95.0, do: :good, else: :bad

    socket
    |> assign(:delivered_power_status, delivered_power_status)
    |> assign(:delivered_power_efficiency, power_efficiency)
    |> assign(:delivered_power_change, power_change)
    |> assign(:delivered_power_change_direction, power_change_direction)
  end

  defp assign_current_simulation_tick(socket) do
    [{_sim_uuid, count}] = SimulationTickCount.get_all()

    assign(socket, :tick_count, count)
  end

  defp current_simulated_time(simulation_started_at, current_time_tick) do
    # 1 day per tick
    time_units = :days
    time_units_per_tick = 1

    total_shift_time_units = current_time_tick * time_units_per_tick

    Timex.shift(
      simulation_started_at,
      [{time_units, total_shift_time_units}]
    )
  end

  defp format_date_simulated_time(simulated_time) do
    {:ok, formatted} = Timex.format(simulated_time, "{YYYY} {Mfull} {D}")

    formatted
  end
end
