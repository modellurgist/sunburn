defmodule SunburnWeb.StatsCard do
  use Phoenix.Component

  attr :headline, :string, required: true
  attr :status, :atom, required: true

  attr :value, :float, required: true
  attr :value_units, :string

  attr :change_direction, :atom, required: true
  attr :change_value, :float, required: true
  attr :change_units, :string

  def component(assigns) do
    ~H"""
    <div class="flex flex-col gap-y-3 lg:gap-y-5 p-4 md:p-5 bg-white border shadow-sm rounded-xl dark:bg-neutral-900 dark:border-neutral-800">
      <div class="inline-flex justify-center items-center">
        <span class={"size-3 inline-block rounded-full me-2 " <> (if @status == :good, do: "bg-green-500", else: "bg-red-500")}>
        </span>
        <span class="text-base font-semibold uppercase text-gray-600 dark:text-neutral-400">
          <%= @headline %>
        </span>
      </div>

      <div class="text-center">
        <h3 class="text-3xl sm:text-4xl lg:text-5xl font-semibold text-gray-800 dark:text-neutral-200">
          <%= @value %>
          <%= @value_units %>
        </h3>
      </div>

      <dl class="flex justify-center items-center divide-x divide-gray-200 dark:divide-neutral-800">
        <dt class="pe-3">
          <span class={if @status == :good, do: "text-green-600", else: "text-red-600"}>
            <span class="inline-block text-lg font-bold">
              <%= @change_value %>
              <%= @change_units %>
            </span>
          </span>
        </dt>
      </dl>
    </div>
    """
  end
end
