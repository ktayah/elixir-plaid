defmodule Plaid.Transfer do
  @moduledoc """
  [Plaid Transfers API](https://plaid.com/docs/transfer) calls and schema.
  """

  defmodule CreateAuthorizationResponse do
    @moduledoc """
    Transfer authorization data structure
    """
    @behaviour Plaid.Castable

    @type t :: %__MODULE__{
            # FIXME: Make this more specific when moving to library
            authorization: map(),
            request_id: String.t()
          }

    defstruct [:authorization, :request_id]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        authorization: generic_map["authorization"],
        request_id: generic_map["request_id"]
      }
    end
  end

  @spec create_authorization(String.t(), map(), Plaid.config()) ::
          {:ok, CreateAuthorizationResponse.t()} | {:error, Plaid.Error.t()}
        when payload: %{
               :account_id => String.t(),
               :type => "debit" | "credit",
               :network => "ach" | "same-day-ach" | "rtp" | "wire",
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
