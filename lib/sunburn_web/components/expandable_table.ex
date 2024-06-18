defmodule SunburnWeb.ExpandableTable do
  use Phoenix.Component

  attr :header, :boolean, required: true
  attr :header_entity_type, :string, required: true
  attr :header_actual_name, :string, default: "Delivered Power"
  attr :header_maximum_name, :string, default: "Maximum Power"
  attr :header_efficiency_name, :string, default: "Delivery Efficiency"

  attr :entity_identifier, :string, required: true
  attr :sites, :list, required: true

  attr :actual_value_units, :string, default: "kWh/day"
  attr :maximum_value_units, :string, default: "kWh/day"

  def component(assigns) do
    ~H"""
    <div class="-m-1.5 overflow-auto">
      <div class="p-1.5 min-w-full inline-block align-middle">
        <div class="overflow-hidden">
          <div class="table border-collapse table-auto w-full divide-y divide-gray-200 dark:divide-neutral-700">
            <div class="table-header-group">
              <div class="table-row font-extrabold">
                <div class="table-cell px-6 py-3 text-start text-gray-500 uppercase dark:text-neutral-500">
                  <%= @header_entity_type %>
                </div>
                <div class="table-cell px-6 py-3 text-start text-end text-gray-500 uppercase dark:text-neutral-500">
                  <%= @header_actual_name %>
                </div>
                <div class="table-cell px-6 py-3 text-start text-end text-gray-500 uppercase dark:text-neutral-500">
                  <%= @header_maximum_name %>
                </div>
              </div>
            </div>
            <div
              :for={site <- @sites}
              class="table-row-group divide-y divide-gray-200 bg-white dark:divide-neutral-700 dark:bg-neutral-800"
            >
              <div class="table-row font-medium">
                <div class="table-cell px-6 py-4 whitespace-nowrap text-gray-800 dark:text-neutral-200">
                  <%= String.slice(site.id, 0, 8) %>
                </div>
                <div class="table-cell px-6 py-4 whitespace-nowrap text-end text-gray-800 dark:text-neutral-200">
                  <%= site.delivered_power %>
                </div>
                <div class="table-cell px-6 py-4 whitespace-nowrap text-end text-gray-800 dark:text-neutral-200">
                  <%= site.maximum_power %>
                </div>
              </div>

              <div class="table-row font-medium">
                <div class="table-cell px-6 py-3 text-center text-gray-500 dark:text-neutral-500">
                  Panel
                </div>
                <div class="table-cell px-6 py-3 text-end text-gray-500 dark:text-neutral-500"></div>
                <div class="table-cell px-6 py-3 text-end text-gray-500 dark:text-neutral-500"></div>
              </div>

              <div :for={panel <- site.panels} class="table-row text-sm font-medium">
                <div class="table-cell px-6 py-4 text-end whitespace-nowrap text-gray-800 dark:text-neutral-200">
                  <%= String.slice(panel.id, 0, 8) %>
                </div>
                <div class="table-cell px-6 py-4 text-end whitespace-nowrap text-gray-800 dark:text-neutral-200">
                  <%= panel.delivered_power %>
                </div>
                <div class="table-cell px-6 py-4 text-end whitespace-nowrap text-gray-800 dark:text-neutral-200">
                  <%= panel.maximum_power %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
