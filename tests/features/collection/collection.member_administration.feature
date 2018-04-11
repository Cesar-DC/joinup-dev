@api @email
Feature: Collection membership administration
  In order to build a community
  As a collection facilitator
  I need to be able to manager collection members

  Background:
    Given the following owner:
      | name         |
      | James Wilson |
    And the following contact:
      | name  | Princeton-Plainsboro Teaching Hospital |
      | email | info@princeton-plainsboro.us           |
    And users:
      | Username          | Roles | E-mail                        | First name | Family name |
      # Authenticated user.
      | Lisa Cuddy        |       | lisa_cuddy@example.com        | Lisa       | Cuddy       |
      | Gregory House     |       | gregory_house@example.com     | Gregory    | House       |
      | Kathie Cumbershot |       | kathie_cumbershot@example.com | Kathie     | Cumbershot  |
      | Donald Duck       |       | donald_duck@example.com       | Donald     | Duck        |
    And the following collections:
      | title             | description               | logo     | banner     | owner        | contact information                    | closed | state     |
      | Medical diagnosis | 10 patients in 10 minutes | logo.png | banner.jpg | James Wilson | Princeton-Plainsboro Teaching Hospital | yes    | validated |
    And the following collection user memberships:
      | collection        | user              | roles                      | state   |
      | Medical diagnosis | Lisa Cuddy        | administrator, facilitator | active  |
      | Medical diagnosis | Gregory House     |                            | active  |
      | Medical diagnosis | Kathie Cumbershot |                            | pending |

  Scenario: Request a membership
    When I am logged in as "Donald Duck"
    And all e-mails have been sent
    And I go to the "Medical diagnosis" collection
    And I press the "Join this collection" button
    Then I should see the success message "Your membership to the Medical diagnosis collection is under approval."
    And the following email should have been sent:
      | recipient | Lisa Cuddy                                                                                                                     |
      | subject   | Joinup: A user has requested to join your collection                                                                           |
      | body      | Donald Duck has requested to join your collection "Medical diagnosis" as a member. To approve or reject this request, click on |

  Scenario: Approve a membership
    # Check that a member with pending state does not have access to add new content.
    When I am logged in as "Kathie Cumbershot"
    And I go to the "Medical diagnosis" collection
    Then I should not see the plus button menu
    And I should not see the link "Add news"

    # Approve a membership.
    When I am logged in as "Lisa Cuddy"
    And all e-mails have been sent
    And I go to the "Medical diagnosis" collection
    Then I click "Members" in the "Left sidebar"
    # Assert that the user does not see the default OG tab.
    Then I should not see the link "Group"
    And I check the box "Update the member Kathie Cumbershot"
    Then I select "Approve the pending membership(s)" from "Action"
    And I press the "Apply to selected items" button
    Then I should see the following success messages:
      | Approve the pending membership(s) was applied to 1 item. |
    And the following email should have been sent:
      | recipient | Kathie Cumbershot                                                               |
      | subject   | Joinup: Your request to join the collection Medical diagnosis was approved      |
      | body      | Lisa Cuddy has approved your request to join the "Medical diagnosis" collection |

    # Check new privileges.
    When I am logged in as "Kathie Cumbershot"
    And I go to the "Medical diagnosis" collection
    # Check that I see one of the random links that requires an active membership.
    Then I should see the plus button menu
    Then I should see the link "Add news"

  @email
  Scenario: Reject a membership
    When I am logged in as "Lisa Cuddy"
    And all e-mails have been sent
    And I go to the "Medical diagnosis" collection
    Then I click "Members" in the "Left sidebar"
    # Assert that the user does not see the default OG tab.
    Then I should not see the link "Group"
    And I check the box "Update the member Kathie Cumbershot"
    Then I select "Delete the selected membership(s)" from "Action"
    And I press the "Apply to selected items" button
    Then I should see the following success messages:
      | Delete the selected membership(s) was applied to 1 item. |
    And the following email should have been sent:
      | recipient | Kathie Cumbershot                                                               |
      | subject   | Joinup: Your request to join the collection Medical diagnosis was rejected      |
      | body      | Lisa Cuddy has rejected your request to join the "Medical diagnosis" collection |

    # Check new privileges.
    When I am logged in as "Kathie Cumbershot"
    And I go to the "Medical diagnosis" collection
    # Check that I see one of the random links that requires an active membership.
    Then I should not see the plus button menu
    And I should see the button "Join this collection"

  @email
  Scenario: Assign a new role to a member
    # Check that Dr House can't edit the collection.
    When I am logged in as "Gregory House"
    And I go to the "Medical diagnosis" collection
    Then I go to the "Medical diagnosis" collection edit form
    Then I should see the heading "Access denied"

    # Dr Cuddy promotes Dr House to facilitator.
    When I am logged in as "Lisa Cuddy"
    And all e-mails have been sent
    And I go to the "Medical diagnosis" collection
    Then I click "Members" in the "Left sidebar"
    # Assert that the user does not see the default OG tab.
    Then I should not see the link "Group"
    Then I check the box "Update the member Gregory House"
    Then I select "Add the facilitator role to the selected members" from "Action"
    And I press the "Apply to selected items" button
    Then I should see the following success messages:
      | Add the facilitator role to the selected members was applied to 1 item. |
    And the following system email should have been sent:
      | recipient | Gregory House                                                                                 |
      | subject   | Your role has been change to Medical diagnosis                                                |
      | body      | A collection moderator has changed your role in this group to Member, Collection facilitator. |

    # Dr House can now edit the collection.
    When I am logged in as "Gregory House"
    And I go to the "Medical diagnosis" collection
    Then I go to the "Medical diagnosis" collection edit form
    Then I should not see the heading "Access denied"

  Scenario: Privileged members should be allowed to add users to a collection.
    Given users:
      | Username  | E-mail                 | First name | Family name |
      | jbelanger | j.belanger@example.com | Jeannette  | Belanger    |
      | dwightone | dwight1@example.com    | Christian  | Dwight      |

    When I am not logged in
    And I go to the "Medical diagnosis" collection
    And I click "Members" in the "Left sidebar"
    Then I should not see the link "Add members"

    When I am logged in as an authenticated
    And I go to the "Medical diagnosis" collection
    And I click "Members" in the "Left sidebar"
    Then I should not see the link "Add members"

    When I am logged in as "dwightone"
    And I go to the "Medical diagnosis" collection
    And I click "Members" in the "Left sidebar"
    Then I should not see the link "Add members"

    When I am logged in as "Lisa Cuddy"
    And I go to the "Medical diagnosis" collection
    And I click "Members" in the "Left sidebar"
    Then I should see the link "Add members"
    When I click "Add members"
    Then I should see the heading "Add members"

    # Verify that a message is shown when no users are selected and we try to submit the form.
    When I press "Add members"
    Then I should see the error message "Please add at least one user."

    When I fill in "E-mail" with "gregory_house@example.com"
    And I press "Add"
    Then the page should show the chips:
      | Gregory House |
    # Verify that an error message is shown when trying to add a mail not
    # present in the system.
    When I fill in "E-mail" with "donald@example.com"
    And I press "Add"
    Then I should see the error message "No user found with mail donald@example.com."
    # Verify that an error message is shown when trying to add the same
    # user twice.
    When I fill in "E-mail" with "gregory_house@example.com"
    And I press "Add"
    Then I should see the error message "The user with mail gregory_house@example.com has been already added to the list."
    # Add some other users.
    When I fill in "E-mail" with "j.belanger@example.com"
    And I press "Add"
    Then the page should show the chips:
      | Jeannette Belanger |
      | Gregory House      |
    When I fill in "E-mail" with "donald_duck@example.com"
    And I press "Add"
    Then the page should show the chips:
      | Jeannette Belanger |
      | Gregory House      |
      | Donald Duck        |
    # Remove a user.
    When I press the remove button on the chip "Donald Duck"
    Then the page should show only the chips:
      | Jeannette Belanger |
      | Gregory House      |
    And I should not see the text "Donald Duck"

    # Add the users as members.
    Given the option with text "Member" from select "Role" is selected
    When I press "Add members"
    Then I should see the success message "Successfully added the role Member to the selected users."
    And I should see the link "Jeannette Belanger"
    And I should see the link "Gregory House"
    But I should not see the link "Donald Duck"

    # Add a facilitator.
    When I click "Add members"
    When I fill in "E-mail" with "dwight1@example.com"
    And I press "Add"
    Then the page should show the chips:
      | Christian Dwight |
    When I select "Facilitator" from "Role"
    And I press "Add members"
    Then I should see the success message "Successfully added the role Collection facilitator to the selected users."
    And I should see the link "Christian Dwight"

    # Try new privileges.
    When I am logged in as "dwightone"
    And I go to the "Medical diagnosis" collection
    And I click "Members" in the "Left sidebar"
    Then I should see the link "Add members"
    When I click "Add members"
    Then I should see the heading "Add members"

    When I am logged in as "jbelanger"
    And I go to the "Medical diagnosis" collection
    And I click "Members" in the "Left sidebar"
    Then I should not see the link "Add members"

  Scenario: Privileged members should be able to filter users in the collection members page.
    Given users:
      | Username   | First name | Family name |
      | emeritous  | King       | Seabrooke   |
      | user049230 | King       | Emerson     |
      | kingseamus | Seamus     | Emerson     |
      | brookebeau | Brooke     | Kingsley    |
      | iambroke   | Nell       | Gibb        |
    And the following collection:
      | title       | Coffee makers                  |
      | description | Coffee is needed for survival. |
      | state       | validated                      |
    And the following collection user memberships:
      | collection    | user       | roles       |
      | Coffee makers | emeritous  | owner       |
      | Coffee makers | user049230 | facilitator |
      | Coffee makers | kingseamus |             |
      | Coffee makers | brookebeau |             |
      | Coffee makers | iambroke   |             |

    When I am logged in as "emeritous"
    And I go to the homepage of the "Coffee makers" collection
    And I click "Members" in the "Left sidebar"
    Then the following fields should be present "Username, First name, Family name"

    When I fill in "Username" with "bro"
    And I press "Apply"
    Then I should see the link "Brooke Kingsley"
    And I should see the link "Nell Gibb"
    But I should not see the link "King Seabrooke"

    When I clear the content of the field "Username"
    When I fill in "First name" with "King"
    And I press "Apply"
    Then I should see the link "King Seabrooke"
    And I should see the link "King Emerson"
    But I should not see the link "Brooke Kingsley"
    And I should not see the link "Seamus Emerson"

    When I clear the field "First name"
    And I fill in "Family name" with "eme"
    And I press "Apply"
    Then I should see the link "King Emerson"
    And I should see the link "Seamus Emerson"
    But I should not see the link "King Seabrooke"

    When I fill in "Username" with "use"
    And I press "Apply"
    Then I should see the link "King Emerson"
    But I should not see the link "Seamus Emerson"
