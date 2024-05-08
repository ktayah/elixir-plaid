defmodule Plaid.Transfer.Transfer do
  alias Plaid.Castable
  alias Plaid.Transfer.User
  alias Plaid.Transfer.Refund
  alias Plaid.Transfer.ExpectedSweepSettlementSchedule

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          id: String.t(),
          authorization_id: String.t(),
          ach_class: String.t(),
          account_id: String.t(),
          funding_account_id: String.t() | nil,
          type: String.t(),
          user: User.t(),
          amount: String.t(),
          description: String.t(),
          created: String.t(),
          refunds: [Refund.t()],
          status: String.t(),
          sweep_status: String.t() | nil,
          network: String.t(),
          wire_details: %{message_to_beneficiary: String.t() | nil} | nil,
          cancellable: boolean(),
          failure_reason:
            %{ach_return_code: String.t() | nil, description: String.t() | nil} | nil,
          metadata: map() | nil,
          iso_currency_code: String.t(),
          standard_return_window: String.t() | nil,
          unauthorized_return_window: String.t() | nil,
          expected_settlement_date: String.t() | nil,
          originator_client_id: String.t() | nil,
          recurring_transfer_id: String.t() | nil,
          credit_funds_source: String.t() | nil,
          facilitator_fee: String.t(),
          network_trace_id: String.t() | nil,
          expected_sweep_settlement_schedule: [ExpectedSweepSettlementSchedule.t()]
        }

  defstruct [
    :id,
    :authorization_id,
    :ach_class,
    :account_id,
    :funding_account_id,
    :type,
    :user,
    :amount,
    :description,
    :created,
    :refunds,
    :status,
    :sweep_status,
    :network,
    :wire_details,
    :cancellable,
    :failure_reason,
    :metadata,
    :iso_currency_code,
    :standard_return_window,
    :unauthorized_return_window,
    :expected_settlement_date,
    :originator_client_id,
    :recurring_transfer_id,
    :credit_funds_source,
    :facilitator_fee,
    :network_trace_id,
    :expected_sweep_settlement_schedule
  ]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      id: generic_map["transfer"]["id"],
      authorization_id: generic_map["transfer"]["authorization_id"],
      ach_class: generic_map["transfer"]["ach_class"],
      account_id: generic_map["transfer"]["account_id"],
      funding_account_id: generic_map["transfer"]["funding_account_id"],
      type: generic_map["transfer"]["type"],
      user: User.cast(generic_map["transfer"]["user"]),
      amount: generic_map["transfer"]["amount"],
      description: generic_map["transfer"]["description"],
      created: generic_map["transfer"]["created"],
      status: generic_map["transfer"]["status"],
      sweep_status: generic_map["transfer"]["sweep_status"],
      refunds: Castable.cast_list(Refund, generic_map["transfer"]["refunds"]),
      network: generic_map["transfer"]["network"],
      wire_details: %{
        message_to_beneficiary: generic_map["transfer"]["wire_details"]["message_to_beneficiary"]
      },
      cancellable: generic_map["transfer"]["cancellable"],
      failure_reason: %{
        ach_return_code: generic_map["transfer"]["failure_reason"]["ach_return_code"],
        description: generic_map["transfer"]["failure_reason"]["description"]
      },
      metadata: generic_map["transfer"]["metadata"],
      iso_currency_code: generic_map["transfer"]["iso_currency_code"],
      standard_return_window: generic_map["transfer"]["standard_return_window"],
      unauthorized_return_window: generic_map["transfer"]["unauthorized_return_window"],
      expected_settlement_date: generic_map["transfer"]["expected_settlement_date"],
      originator_client_id: generic_map["transfer"]["originator_client_id"],
      recurring_transfer_id: generic_map["transfer"]["recurring_transfer_id"],
      credit_funds_source: generic_map["transfer"]["credit_funds_source"],
      facilitator_fee: generic_map["transfer"]["facilitator_fee"],
      network_trace_id: generic_map["transfer"]["network_trace_id"],
      expected_sweep_settlement_schedule:
        Castable.cast_list(
          ExpectedSweepSettlementSchedule,
          generic_map["transfer"]["expected_sweep_settlement_schedule"]
        )
    }
  end
end
