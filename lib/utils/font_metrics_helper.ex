defmodule FloUI.Util.FontMetricsHelper do
  @moduledoc false

  require Logger
  # @font_metrics FloUI.Util.FontMetricsHelper.get_font_metrics()
  @default_font :roboto
  @default_font_size 16

  def get_font_metrics() do
    {:ok, {_, fm}} = Scenic.Assets.Static.meta(@default_font)
    fm
  end

  def get_font_ascent(font_size \\ @default_font_size) do
    FontMetrics.ascent(font_size, get_font_metrics())
  end

  def get_font_descent(font_size \\ @default_font_size) do
    FontMetrics.descent(font_size, get_font_metrics())
  end

  def get_text_width(text, font_size \\ @default_font_size) do
    FontMetrics.width(text, font_size, get_font_metrics())
  end

  def get_text_height(font_size \\ @default_font_size) do
    font_size + get_font_ascent(font_size)
  end

  def get_text_center_y(font_size \\ @default_font_size) do
    font_size / 2
  end

  def get_component_width(text, font_size \\ @default_font_size) do
    ascent = get_font_ascent(font_size)
    get_text_width(text, font_size) + ascent * 3
  end
end
