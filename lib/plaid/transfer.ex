defmodule Plaid.Transfer do
  @moduledoc """
  [Plaid Transfers API](https://plaid.com/docs/transfer) calls and schema.
  """

  defmodule TransferAuthorization do
    @moduledoc """
    Transfer authorization data structure
    """
    @behaviour Plaid.Castable

    @type decision_rationale :: %{
            code: String.t(),
            description: String.t()
          }

    @type guarantee_decision_rationale :: %{
            code: String.t(),
            description: String.t()
          }

    @type proposed_transfer :: %{
            ach_class: String.t(),
            account_id: String.t(),
            funding_account_id: String.t() | nil,
            type: String.t(),
            user: Plaid.Transfer.User.t(),
            amount: String.t(),
            network: String.t(),
            wire_details: map() | nil,
            origination_account_id: String.t(),
            iso_currency_code: String.t(),
            originator_client_id: String.t()
          }

    @type payment_risk :: %{
            bank_initiated_return_score: pos_integer() | nil,
            customer_initiated_return_score: pos_integer() | nil,
            risk_level: String.t() | nil,
            warnings: %{
              warning_type: String.t(),
              warning_code: String.t(),
              warning_message: String.t()
            }
          }

    @type t :: %__MODULE__{
            id: String.t(),
            created: String.t(),
            decision: String.t() | nil,
            decision_rationale: decision_rationale(),
            guarantee_decision: String.t() | nil,
            guarantee_decision_rationale: guarantee_decision_rationale(),
            payment_risk: payment_risk() | nil,
            proposed_transfer: proposed_transfer()
          }

    defstruct [
      :id,
      :created,
      :decision,
      :decision_rationale,
      :guarantee_decision,
      :guarantee_decision_rationale,
      :proposed_transfer,
      :payment_risk
    ]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        id: generic_map["id"],
        created: generic_map["created"],
        decision: generic_map["decision"],
        decision_rationale: generic_map["decision_rationale"],
        guarantee_decision: generic_map["guarantee_decision"],
        guarantee_decision_rationale: generic_map["guarantee_decision_rationale"],
        proposed_transfer: %{
          account_id: generic_map["proposed_transfer"]["account_id"],
          ach_class: generic_map["proposed_transfer"]["ach_class"],
          amount: generic_map["proposed_transfer"]["amount"],
          credit_funds_source: generic_map["proposed_transfer"]["credit_funds_source"],
          funding_account_id: generic_map["proposed_transfer"]["funding_account_id"],
          iso_currency_code: generic_map["proposed_transfer"]["iso_currency_code"],
          network: generic_map["proposed_transfer"]["network"],
          origination_account_id: generic_map["proposed_transfer"]["origination_account_id"],
          originator_client_id: generic_map["proposed_transfer"]["originator_client_id"],
          type: generic_map["proposed_transfer"]["type"],
          user: Plaid.Transfer.User.cast(generic_map["proposed_transfer"]["user"])
        },
        payment_risk: %{
          bank_initiated_return_score: generic_map["payment_risk"]["bank_initiated_return_score"],
          customer_initiated_return_score:
            generic_map["payment_risk"]["customer_initiated_return_score"],
          risk_level: generic_map["payment_risk"]["risk_level"],
          warnings: %{
            warning_type: generic_map["payment_risk"]["warnings"]["warning_type"],
            warning_code: generic_map["payment_risk"]["warnings"]["warning_code"],
            warning_message: generic_map["payment_risk"]["warnings"]["warning_message"]
          }
        }
      }
    end
  end

  defmodule CreateAuthorizationResponse do
    @moduledoc """
    Transfer authorization create response data structure
    """
    @behaviour Plaid.Castable

    @type t :: %__MODULE__{
            authorization: TransferAuthorization.t(),
            request_id: String.t()
          }

    defstruct [:authorization, :request_id]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        authorization: TransferAuthorization.cast(generic_map["authorization"]),
        request_id: generic_map["request_id"]
      }
    end
  end

  @spec create_authorization(String.t(), payload, Plaid.config()) ::
          {:ok, CreateAuthorizationResponse.t()} | {:error, Plaid.Error.t()}
        when payload: %{
               :account_id => String.t(),
               :type => String.t(),
               :network => String.t(),
               :amount => String.t(),
               :user => Plaid.Transfer.User.t(),
               optional(:funding_account_id) => String.t(),
               optional(:payment_profile_token) => String.t(),
               optional(:ach_class) => String.t(),
               optional(:wire_details) => map(),
               optional(:device) => map(),
               optional(:origination_account_id) => String.t(),
               optional(:iso_currency_code) => String.t(),
               optional(:idempotency_key) => String.t(),
               optional(:user_present) => boolean(),
               optional(:with_guarantee) => boolean(),
               optional(:beacon_session_id) => String.t(),
               optional(:originator_client_id) => String.t(),
               optional(:credit_funds_source) => map(),
               optional(:test_clock_id) => String.t()
             }
  def create_authorization(access_token, params, config) do
    payload = Map.merge(params, %{access_token: access_token})

    Plaid.Client.call(
      "/transfer/authorization/create",
      payload,
      CreateAuthorizationResponse,
      config
    )
  end

  defmodule Refund do
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

  defmodule ExpectedSweepSettlementSchedule do
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

  defmodule CreateResponse do
    alias Plaid.Castable
    @behaviour Plaid.Castable

    @type transfer_map :: %{
            id: String.t(),
            authorization_id: String.t(),
            ach_class: String.t(),
            account_id: String.t(),
            funding_account_id: String.t() | nil,
            type: String.t(),
            user: Plaid.Transfer.User.t(),
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

    @type t :: %__MODULE__{
            transfer: transfer_map,
            request_id: String.t()
          }

    defstruct [:transfer, :request_id]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        transfer: %{
          id: generic_map["transfer"]["id"],
          authorization_id: generic_map["transfer"]["authorization_id"],
          ach_class: generic_map["transfer"]["ach_class"],
          account_id: generic_map["transfer"]["account_id"],
          funding_account_id: generic_map["transfer"]["funding_account_id"],
          type: generic_map["transfer"]["type"],
          user: Plaid.Transfer.User.cast(generic_map["transfer"]["user"]),
          amount: generic_map["transfer"]["amount"],
          description: generic_map["transfer"]["description"],
          created: generic_map["transfer"]["created"],
          status: generic_map["transfer"]["status"],
          sweep_status: generic_map["transfer"]["sweep_status"],
          refunds: Castable.cast_list(Refund, generic_map["transfer"]["refunds"]),
          network: generic_map["transfer"]["network"],
          wire_details: %{
            message_to_beneficiary:
              generic_map["transfer"]["wire_details"]["message_to_beneficiary"]
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
        },
        request_id: generic_map["request_id"]
      }
    end
  end

  @spec create(String.t(), payload, Plaid.config()) ::
          {:ok, CreateResponse.t()} | {:error, Plaid.Error.t()}
        when payload: %{
               :account_id => String.t(),
               :authorization_id => String.t(),
               :description => String.t(),
               optional(:amount) => String.t(),
               optional(:metadata) => map(),
               optional(:test_clock_id) => String.t(),
               optional(:facilitator_fee) => String.t()
             }
  def create(access_token, params, config) do
    payload = Map.merge(params, %{access_token: access_token})
    Plaid.Client.call("/transfer/create", payload, CreateResponse, config)
  end

  @spec cancel(%{transfer_id: String.t()}, Plaid.config()) ::
          {:ok, Plaid.SimpleResponse.t()} | {:error, Plaid.Error.t()}
  def cancel(params, config) do
    Plaid.Client.call("/transfer/cancel", params, Plaid.SimpleResponse, config)
  end
end
