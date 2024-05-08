defmodule Plaid.Transfer.ExpectedSweepSettlementSchedule do
  @moduledoc """
  Plaid.Transfer.ExpectedSweepSettlementSchedule data structure
  """
  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          sweep_settlement_date: String.t(),
          swept_settled_amount: String.t()
        }

  defstruct [:sweep_settlement_date, :swept_settled_amount]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      sweep_settlement_date: generic_map["sweep_settlement_date"],
      swept_settled_amount: generic_map["swept_settled_amount"]
    }
  end
end
