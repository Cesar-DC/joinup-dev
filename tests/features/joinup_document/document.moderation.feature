@api
Feature: Document moderation
  In order to manage documents
  As a user of the website
  I need to be able to transit the documents from one state to another.

  Background:
    Given users:
      | name            |
      | Crab y Patties  |
      | Gretchen Greene     |
      | Kirk Collier |
    And the following owner:
      | name          |
      | thisisanowner |
    And the following collection:
      | title             | The Naked Ashes                 |
      | description       | The wolverine is a Marvel hero. |
      | logo              | logo.png                        |
      | banner            | banner.jpg                      |
      | elibrary creation | registered users                |
      | moderation        | no                              |
      | state             | validated                       |
      | owner             | thisisanowner                   |
      | policy domain     | Demography and population       |
    And the following collection user membership:
      | collection      | user            | roles       |
      | The Naked Ashes | Gretchen Greene     | member      |
      | The Naked Ashes | Kirk Collier | facilitator |

  Scenario: Available transitions change per eLibrary and moderation settings.
    # For post moderated collections with eLibrary set to allow all users, even
    # authenticated users can create content.
    When I am logged in as "Crab y Patties"
    And go to the homepage of the "The Naked Ashes" collection
    And I click "Add document" in the plus button menu
    # Post moderated collections allow publishing content directly.
    And I should see the button "Publish"

    # Changing settings to the collection should affect the allowed transitions.
    When I am logged in as a moderator
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "Edit" in the "Entity actions" region
    And I check the box "Moderated"
    Then I press "Publish"
    And I should see the heading "The Naked Ashes"

    # The authenticated user should still be able to create content but not
    # publish it.
    When I am logged in as "Crab y Patties"
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "Add document" in the plus button menu
    Then I should not see the button "Publish"
    But I should see the button "Save as draft"
    And I should see the button "Request approval"

    # The eLibrary should block access for specific users.
    When I am logged in as a moderator
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "Edit" in the "Entity actions" region
    And I check "Closed collection"
    And I select "Only members can create new content." from "eLibrary creation"
    Then I press "Publish"
    And I should see the link "Add document"

    # The authenticated user should still be able to create content but not
    # publish it.
    When I am logged in as "Crab y Patties"
    And I go to the homepage of the "The Naked Ashes" collection
    Then I should not see the link "Add document"

  Scenario: Transit documents from one state to another.
    When I am logged in as "Gretchen Greene"
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "Add document"
    When I fill in the following:
      | Title       | An amazing document                      |
      | Short title | Amazing document                         |
      | Description | This is going to be an amazing document. |
    And I attach the file "test.zip" to "File"
    And I press "Save as draft"
    Then I should see the success message "Document An amazing document has been created"

    # Publish the content.
    When I click "Edit" in the "Entity actions" region
    And I fill in "Title" with "A not so amazing document"
    And I press "Publish"
    Then I should see the heading "A not so amazing document"

    # Request modification as facilitator.
    When I am logged in as "Kirk Collier"
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "A not so amazing document"
    And I click "Edit" in the "Entity actions" region
    Then I should see the button "Request changes"
    And I press "Request changes"

    # Implement changes.
    When I am logged in as "Gretchen Greene"
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "A not so amazing document"
    And I click "Edit" in the "Entity actions" region
    And I fill in "Title" with "The document is amazing"
    And I press "Update proposed"
    Then I should see the heading "A not so amazing document"

    # Approve changes as facilitator.
    When I am logged in as "Kirk Collier"
    And I go to the homepage of the "The Naked Ashes" collection
    And I click "A not so amazing document"
    And I click "Edit" in the "Entity actions" region
    Then I should see the button "Approve proposed"
    And I press "Approve proposed"
    Then I should see the heading "The document is amazing"
