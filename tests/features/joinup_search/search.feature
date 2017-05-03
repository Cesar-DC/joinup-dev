@api
Feature: Global search
  As a user of the site I can find content through the global search.

  Scenario: Anonymous user can find items
    Given the following solutions:
      | title          | description                                                                                                                        | state     |
      | Spherification | Spherification is the culinary process of shaping a liquid into spheres                                                            | validated |
      | Foam           | The use of foam in cuisine has been used in many forms in the history of cooking:whipped cream, meringue, and mousse are all foams | validated |
      # Taxonomies are not yet implemented, so uncomment this after #ISAICP-2545 is done
      # | spatial coverage | http://publications.europa.eu/resource/authority/country/EUR            |
    And the following collection:
      | title      | Molecular cooking collection |
      | logo       | logo.png                     |
      | moderation | no                           |
      | affiliates | Spherification, Foam         |
      | state      | validated                    |
    And news content:
      | title                 | body             | collection                   | state     |
      | El Celler de Can Roca | The best in town | Molecular cooking collection | validated |

    Given I am logged in as a user with the "authenticated" role
    When I am at "/search"
    # All content visible
    Then I should see the text "Molecular cooking collection"
    Then I should see the text "El Celler de Can Roca"
    Then I should see the text "Spherification"
    Then I should see the text "Foam"

    # Select link in the 'type' facet.
    Then I click "solution" in the "Left sidebar" region
    # @todo Re-enable this check when the tile view mode created.
    # (The default view mode of solutions holds a link to it's collection)
    # Then I should not see the text "Molecular cooking collection"
    Then I should not see the text "El Celler de Can Roca"
    Then I should see the text "Spherification"
    Then I should see the text "Foam"

  @terms
  Scenario: Content can be found with a full-text search.
    Given the following owner:
      | name              | type    |
      | Responsible owner | Company |
    And the following contact:
      | name  | Go-to contact     |
      | email | go-to@example.com |
    And the following collections:
      | title            | description                                                  | abstract                       | state     |
      | Collection alpha | <p>This is the collection <strong>beta</strong> description. | The collection gamma abstract. | validated |
    And the following solutions:
      | title          | description                                                | keywords | owner             | contact information | state     |
      | Solution alpha | <p>This is the solution <strong>beta</strong> description. | Alphabet | Responsible owner | Go-to contact       | validated |
    And the following releases:
      | title         | release notes                               | keywords | is version of  | owner             | contact information | state     |
      | Release Alpha | <p>Release notes for <em>beta</em> changes. | Alphabet | Solution alpha | Responsible owner | Go-to contact       | validated |
    And the following distributions:
      | title              | description                                    | parent        | access url |
      | Distribution alpha | <p>A simple beta distribution description.</p> | Release Alpha | test.zip   |
    And the following licences:
      | title         | description                         |
      | Licence Alpha | A beta description for the licence. |
    And news content:
      | title      | headline            | body                      | keywords | collection       | state     |
      | News omega | News headline delta | The epsilon news content. | Alphabet | Collection alpha | validated |
    And event content:
      | title             | short title       | body                                | agenda         | location       | additional info address | organisation        | scope         | keywords | collection       | solution       | state     |
      | Event Omega       | Event short delta | The epsilon event content.          | Event agenda.  | Some place     | Event address           | European Commission | International | Alphabet |                  | Solution alpha | validated |
      | Alternative event | Alt event         | This event stays in the background. | To be planned. | Event location | Rue de events           | Event organisation  |               |          | Collection alpha |                | validated |
    And document content:
      | title          | type     | short title          | body                                    | keywords | collection       | state     |
      | Document omega | Document | Document short delta | A document consists of epsilon strings. | Alphabet | Collection alpha | validated |
    And discussion content:
      | title            | body                                                              | solution       | state     |
      | Discussion omega | <p>Does anybody has idea why this <em>epsilon</em> is everywhere? | Solution alpha | validated |
    # Currently no UI path allows the creation of newsletters. Search for migrated D6 newsletters instead.
    # Ignore all steps related to newsletters in this test in UAT.
    # @see: https://webgate.ec.europa.eu/CITnet/jira/browse/ISAICP-2256
    And newsletter content:
      | title            | body                                  |
      | Newsletter omega | Talking about these epsilon contents. |
    And custom_page content:
      | title      | body                                    | collection       |
      | Page omega | This is just a epsilon but should work. | Collection alpha |
    And users:
      | Username     | E-mail                      | First name | Family name | Organisation |
      | jenlyle      | jenessa.carlyle@example.com | Jenessa    | Carlyle     | Clyffco      |
      | ulyssesfrees | ulysses.freeman@example.com | Ulysses    | Freeman     | Omero snc    |

    # "Alpha" is used in all the rdf entities titles.
    When I enter "Alpha" in the header search bar and hit enter
    Then the page should show the tiles "Collection alpha, Solution alpha, Release Alpha, Distribution alpha"
    And I should see the text "Licence Alpha"
    And I should not see the text "Newsletter omega"

    # "Omega" is used in all the node entities titles.
    When I enter "omega" in the header search bar and hit enter
    Then the page should show the tiles "News omega, Event Omega, Document omega, Discussion omega, Page omega"
    And I should see the text "Newsletter omega"
    And I should not see the text "Licence Alpha"

    # "Beta" is used in all the rdf entities body fields.
    When I enter "beta" in the header search bar and hit enter
    Then the page should show the tiles "Collection alpha, Solution alpha, Release Alpha, Distribution alpha"
    And I should see the text "Licence Alpha"
    And I should not see the text "Newsletter omega"

    # "Epsilon" is used in all the node entities body fields.
    When I enter "epsilon" in the header search bar and hit enter
    Then the page should show the tiles "News omega, Event Omega, Document omega, Discussion omega, Page omega"
    And I should see the text "Newsletter omega"
    And I should not see the text "Licence Alpha"

    # "Alphabet" is used in all the keywords fields.
    When I enter "Alphabet" in the header search bar and hit enter
    Then the page should show the tiles "Solution alpha, Release Alpha, News omega, Event Omega, Document omega"
    And I should not see the text "Licence Alpha"
    And I should not see the text "Newsletter omega"

    # "Gamma" is used in the collection abstract.
    When I enter "gamma" in the header search bar and hit enter
    Then the page should show the tiles "Collection alpha"
    And I should not see the text "Licence Alpha"
    And I should not see the text "Newsletter omega"

    # "Delta" is used in headline and short titles.
    When I enter "delta" in the header search bar and hit enter
    Then the page should show the tiles "News omega, Event Omega, Document omega"
    And I should not see the text "Newsletter omega"
    And I should not see the text "Licence Alpha"

    # Search for the event fields: agenda, location, address, organisation, scope.
    When I enter "agenda" in the header search bar and hit enter
    Then the page should show the tiles "Event Omega"
    When I enter "location" in the header search bar and hit enter
    Then the page should show the tiles "Alternative event"
    When I enter "address" in the header search bar and hit enter
    Then the page should show the tiles "Event Omega"
    When I enter "organisation" in the header search bar and hit enter
    Then the page should show the tiles "Alternative event"
    When I enter "international" in the header search bar and hit enter
    Then the page should show the tiles "Event Omega"

    # The owner and contact information names should be indexed inside the solutions/releases they are linked to.
    When I enter "responsible" in the header search bar and hit enter
    Then the page should show the tiles "Solution alpha, Release Alpha"
    # Visit the homepage to be sure that the test fetches the correct updated page.
    When I go to the homepage
    And I enter "contact" in the header search bar and hit enter
    Then the page should show the tiles "Solution alpha, Release Alpha"

    # Users should be found by first name, family name and organisation.
    When I enter "Jenessa" in the header search bar and hit enter
    Then the page should show the tiles "Carlyle Jenessa"
    When I enter "freeman" in the header search bar and hit enter
    Then the page should show the tiles "Freeman Ulysses"
    When I enter "clyffco" in the header search bar and hit enter
    Then the page should show the tiles "Carlyle Jenessa"
    When I enter "Omero+snc" in the header search bar and hit enter
    Then the page should show the tiles "Freeman Ulysses"
