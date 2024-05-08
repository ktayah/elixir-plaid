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

  test "/transfer/create", %{bypass: bypass, api_host: api_host} do
    Bypass.expect_once(bypass, "POST", "/transfer/create", fn conn ->
      Conn.resp(conn, 200, ~s<{
        "transfer": {
          "id": "460cbe92-2dcc-8eae-5ad6-b37d0ec90fd9",
          "authorization_id": "c9f90aa1-2949-c799-e2b6-ea05c89bb586",
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
          "description": "payment",
          "created": "2020-08-06T17:27:15Z",
          "refunds": [],
          "status": "pending",
          "sweep_status": [],
          "network": "ach",
          "cancellable": true,
          "guarantee_decision": null,
          "guarantee_decision_rationale": null,
          "failure_reason": null,
          "metadata": {
            "key1": "value1",
            "key2": "value2"
          },
          "iso_currency_code": "USD",
          "standard_return_window": "2023-08-07",
          "unauthorized_return_window": "2023-10-07",
          "expected_settlement_date": "2023-08-04",
          "originator_client_id": "569ed2f36b3a3a021713abc1",
          "recurring_transfer_id": null,
          "credit_funds_source": "sweep",
          "facilitator_fee": "1.23",
          "network_trace_id": null
        }
      }>)
    end)

    assert {:ok, _} =
             Plaid.Transfer.create(
               "access-prod-123xxx",
               %{
                 account_id: "3gE5gnRzNyfXpBK5wEEKcymJ5albGVUqg77gr",
                 authorization_id: "231h012308h3101z21909sw",
                 description: "Payment",
                 metadata: %{key1: "value1", key2: "value2"},
                 test_clock_id: "test_clock_id",
                 facilitator_fee: "1.23"
               },
               test_api_host: api_host,
               client_id: "123",
               secret: "abc"
             )
  end

  test "/transfer/cancel", %{bypass: bypass, api_host: api_host} do
    Bypass.expect_once(bypass, "POST", "/transfer/cancel", fn conn ->
      Conn.resp(conn, 200, ~s<{"request_id": "saKrIBuEB9qJZno"}>)
    end)

    assert {:ok, %Plaid.SimpleResponse{request_id: "saKrIBuEB9qJZno"}} =
             Plaid.Transfer.cancel(%{transfer_id: "123004561178933"},
               test_api_host: api_host,
               client_id: "123",
               secret: "abc"
             )
  end
end
