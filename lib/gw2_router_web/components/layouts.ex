defmodule Gw2RouterWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use Gw2RouterWeb, :controller` and
  `use Gw2RouterWeb, :live_view`.
  """
  use Gw2RouterWeb, :html

  embed_templates "layouts/*"
end
