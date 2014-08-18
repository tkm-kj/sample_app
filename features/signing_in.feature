Feature: Signing in

  Scenario: Unsuccessful signin
    Given サインインページに飛ぶお
    When he submits invalid signin information
    Then he should see an error message

  Scenario: Successful signin
    Given サインインページに飛ぶお
    And the user has an account
    When the user submits valid signin information
    Then he should see his profile page
    And he should see a signout link
