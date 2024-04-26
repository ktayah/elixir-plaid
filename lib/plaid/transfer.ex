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
            # authorization: map(),
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
end
