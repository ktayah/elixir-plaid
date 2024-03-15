defmodule Plaid.Transfer.User do
  @moduledoc """
  Transfer user data structure
  """
  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          :legal_name => String.t(),
          optional(:phone_number) => String.t(),
          optional(:email_address) => String.t(),
          optional(:address) => Plaid.Address.t()
        }

  defstruct [:legal_name, :phone_number, :email_address, :address]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      legal_name: generic_map["legal_name"],
      phone_number: generic_map["phone_number"],
      email_address: generic_map["email_address"],
      address: Plaid.Address.cast(generic_map["address"])
    }
  end
end
