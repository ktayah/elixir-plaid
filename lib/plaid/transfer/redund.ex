defmodule Plaid.Transfer.Refund do
  @moduledoc """
  Plaid.Transfer.Refund data structure
  """
  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          id: String.t(),
          transfer_id: String.t(),
          amount: String.t(),
          status: String.t(),
          failure_reason: %{ach_return_code: String.t() | nil, description: String.t()} | nil,
          created: String.t(),
          network_trace_id: String.t() | nil
        }

  defstruct [:id, :transfer_id, :amount, :status, :failure_reason, :created, :network_trace_id]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      id: generic_map["id"],
      transfer_id: generic_map["transfer_id"],
      amount: generic_map["amount"],
      status: generic_map["status"],
      created: generic_map["created"],
      network_trace_id: generic_map["network_trace_id"],
      failure_reason: cast_failure_reason(generic_map["failure_reason"])
    }
  end

  defp cast_failure_reason(nil), do: nil

  defp cast_failure_reason(failure_reason) when is_map(failure_reason) do
    %{
      ach_return_code: failure_reason["ach_return_code"],
      description: failure_reason["description"]
    }
  end
end
