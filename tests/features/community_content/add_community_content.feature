@api
Feature: Add community content
  In order to introduce my wisdom in my collections
  As a member of a collection
  I need to be able to add community content

  Scenario Outline: Advanced content and group administration should not be accessible for group members
    Given the following collection:
      | title | The night shift |
      | state | validated       |

    When I am logged in as a "<member type>" of the "The night shift" collection
    And I go to the homepage of the "The night shift" collection
    And I click "Add <content type>"
    Then I should see the heading "Add <content type>"
    But I should not see the following lines of text:
      | Authored by                  |
      | Authored on                  |
      | Create new revision          |
      | Generate automatic URL alias |
      | Groups audience              |
      | Other groups                 |
      | Promoted to front page       |
      | Revision information         |
      | Revision log message         |
      | Sticky at top of lists       |

    Examples:
      | member type | content type |
      | facilitator | discussion   |
      | facilitator | document     |
      | facilitator | event        |
      | facilitator | news         |
      | member      | discussion   |
      | member      | document     |
      | member      | event        |
      | member      | news         |

  Scenario Outline: Advanced content and group administration should not be accessible for moderators
    Given the following collection:
      | title | The night shift |
      | state | validated       |

    When I am logged in as a "moderator"
    And I go to the homepage of the "The night shift" collection
    And I click "Add <content type>"
    Then I should see the heading "Add <content type>"
    And the following fields should be present "Authored by"
    But I should not see the following lines of text:
      | Authored on                  |
      | Create new revision          |
      | Generate automatic URL alias |
      | Groups audience              |
      | Other groups                 |
      | Promoted to front page       |
      | Revision information         |
      | Revision log message         |
      | Sticky at top of lists       |

    Examples:
      | content type |
      | discussion   |
      | document     |
      | event        |
      | news         |

  Scenario Outline: Publishing a content for the first time updates the creation time
    Given users:
      | Username  | E-mail                     | First name | Family name    |
      | Publisher | publisher-example@test.com | Publihser  | Georgakopoulos |
    And the following collection:
      | title | The afternoon shift |
      | state | validated           |
    And the following collection user membership:
      | collection          | user      | role        |
      | The afternoon shift | Publisher | facilitator |
    And discussion content:
      | title             | content         | author    | state | collection          | created    |
      | Sample discussion | Sample content. | Publisher | draft | The afternoon shift | 01-01-2010 |
    And event content:
      | title        | body            | location        | author    | collection          | state | created    |
      | Sample event | Sample content. | Sample location | Publisher | The afternoon shift | draft | 01-01-2010 |
    And news content:
      | title       | headline    | body            | state | author    | collection          | created    |
      | Sample news | Sample news | Sample content. | draft | Publisher | The afternoon shift | 01-01-2010 |

    When I am logged in as "Publisher"
    And I go to the "Sample <content type>" <content type>
    And I should see the text "01/01/2010"
    And I click "Edit" in the "Entity actions" region
    And I press "Publish"
    Then I should see the heading "Sample <content type>"
    And the created date of the "Sample <content type>" <content type> should be different than its unpublished version
    # The created date has been updated.
    And I should not see the text "01/01/2010"

    # Obtain a new request time.
    When I reload the page
    When I click "Edit" in the "Entity actions" region
    And I press "Save new draft"
    When I click "Edit" in the "Entity actions" region
    And I press "Publish"
    Then the created date of the "Sample <content type>" <content type> should be the same as the last published version

    # The document is not tested as the creation date is not shown in the page. For documents, the document publication
    # date is the one shown and this field is exposed to the user.
    Examples:
      | content type |
      | discussion   |
      | event        |
      | news         |
