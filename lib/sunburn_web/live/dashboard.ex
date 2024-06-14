defmodule SunburnWeb.Dashboard do
  use SunburnWeb, :live_view

  alias SunburnWeb.StatsCard

  @impl true
  def mount(_params, _session, socket) do
    values = [
      %{key: "0", leaf: true, label: "Item 0", data: %{name: "Item 0"}, children: []}
    ]

    socket =
      socket
      |> assign(:values, values)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full grid grid-cols-11">
      <div class="col-start-5 col-span-3">
        <StatsCard.component
          headline="Successful conversions"
          status={:good}
          value={95.0}
          value_units="%"
          change_direction={:positive}
          change_value={5.6}
          change_units="%"
        />
      </div>
    </div>
    """
  end
end
