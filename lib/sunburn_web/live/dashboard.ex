defmodule SunburnWeb.Dashboard do
  use SunburnWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    values = [
      %{key: "0", leaf: true, label: "Item 0", data: %{name: "Item 0"}, children: []}
    ]

    socket =
      socket
      |> assign(:count, 0)
      |> assign(:values, values)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex">
      <.vue
        v-component="Counter"
        v-ssr={true}
        v-socket={@socket}
        count={@count}
        v-on:inc={JS.push("inc")}
      />

      <.vue
        v-component="Tree"
        v-ssr={true}
        v-socket={@socket}
        values={@values}
      />
    </div>
    """
  end

  @impl true
  def handle_event("inc", %{"value" => diff}, socket) do
    {:noreply, update(socket, :count, &(&1 + diff))}
  end
end
