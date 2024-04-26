defmodule Plaid.AccountsTest do
  use ExUnit.Case, async: true

  alias Plug.Conn

  setup do
    bypass = Bypass.open()
    api_host = "http://localhost:#{bypass.port}/"
    %{bypass: bypass, api_host: api_host}
  end

  test "/transfer/authorization/create", %{bypass: bypass, api_host: api_host} do
    Bypass.expect_once(bypass, "POST", "/transfer/authorization/create", fn conn ->
      Conn.resp(conn, 200, ~s<{
        "authorization": {
          "id": "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9",
          "created": "2020-08-06T17:27:15Z",
          "decision": "approved",
          "decision_rationale": null,
          "guarantee_decision": null,
          "guarantee_decision_rationale": null,
          "payment_risk": {
            "bank_initiated_return_score": 50,
            "customer_initiated_return_score": 1,
            "risk_level": "MEDIUM_RISK",
            "warnings": {
              "warning_type": "a warning type",
              "warning_code": "a warning code",
              "warning_message": "a warning message"
            }
          },
          "proposed_transfer": {
            "ach_class": "ppd",
            "account_id": "3gE5gnRzNyfXpBK5wEEKcymJ5albGVUqg77gr",
            "funding_account_id": "8945fedc-e703-463d-86b1-dc0607b55460",
            "type": "credit",
            "user": {
              "legal_name": "Anne Charleston",
              "phone_number": "510-555-0128",
              "email_address": "acharleston@email.com",
              "address": {
                "street": "123 Main St.",
                "city": "San Francisco",
                "region": "CA",
                "postal_code": "94053",
                "country": "US"
              }
            },
            "amount": "12.34",
            "network": "ach",
            "iso_currency_code": "USD",
            "origination_account_id": "",
            "originator_client_id": null,
            "credit_funds_source": "sweep"
          }
        },
        "request_id": "saKrIBuEB9qJZno"
      }>)
    end)

    {:ok,
     %Plaid.Transfer.CreateAuthorizationResponse{
       authorization: %Plaid.Transfer.TransferAuthorization{
         id: "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9",
         created: "2020-08-06T17:27:15Z",
         decision: "approved",
         decision_rationale: nil,
         guarantee_decision: nil,
         guarantee_decision_rationale: nil,
         proposed_transfer: %{
           type: "credit",
           ach_class: "ppd",
           account_id: "3gE5gnRzNyfXpBK5wEEKcymJ5albGVUqg77gr",
           funding_account_id: "8945fedc-e703-463d-86b1-dc0607b55460",
           amount: "12.34",
           network: "ach",
           origination_account_id: "",
           iso_currency_code: "USD",
           originator_client_id: nil,
           credit_funds_source: "sweep",
           user: %{
             legal_name: "Anne Charleston",
             phone_number: "510-555-0128",
             email_address: "acharleston@email.com",
             address: %{
               street: "123 Main St.",
               city: "San Francisco",
               region: "CA",
               postal_code: "94053",
               country: "US"
             }
           }
         },
         payment_risk: %{
           warnings: %{
             warning_message: "a warning message",
             warning_type: "a warning type",
             warning_code: "a warning code"
           },
           bank_initiated_return_score: 50,
           customer_initiated_return_score: 1,
           risk_level: "MEDIUM_RISK"
         }
       },
       request_id: "saKrIBuEB9qJZno"
     }} =
      Plaid.Transfer.create_authorization(
        "access-prod-123xxx",
        %{
          account_id: "some account-id",
          type: "debit",
          network: "ach",
          amount: "100.00",
          user: %{legal_name: "John Smith"}
        },
        test_api_host: api_host,
        client_id: "123",
        secret: "abc"
      )
  end
end
