defmodule DemoWeb.LayoutView do
  use DemoWeb, :view
  def env() do
    Application.get_env(:demo, :environment, :dev)
  end

  def is_prod(), do: env() == :prod
end
