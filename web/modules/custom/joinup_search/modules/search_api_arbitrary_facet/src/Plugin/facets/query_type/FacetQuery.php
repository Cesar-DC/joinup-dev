<?php

namespace Drupal\search_api_arbitrary_facet\Plugin\facets\query_type;

use Drupal\facets\Plugin\facets\query_type\SearchApiString;
use Drupal\facets\Result\Result;

/**
 * Provides supports for facets generated by arbitrary queries.
 *
 * @see https://wiki.apache.org/solr/SimpleFacetParameters#facet.query_:_Arbitrary_Query_Faceting
 *
 * @FacetsQueryType(
 *   id = "facet_query",
 *   label = @Translation("Arbitrary facet query"),
 * )
 */
class FacetQuery extends SearchApiString {

  /**
   * {@inheritdoc}
   */
  public function execute() {
    $query = $this->query;
    if (empty($query)) {
      return;
    }

    // Set the options for the actual query.
    $options = &$query->getOptions();

    $operator = $this->facet->getQueryOperator();
    $field_identifier = $this->facet->getFieldIdentifier();
    $exclude = $this->facet->getExclude();
    $options['search_api_arbitrary_facet'][$field_identifier] = [
      'limit' => $this->facet->getHardLimit(),
      'operator' => $operator,
      'min_count' => $this->facet->getMinCount(),
      'missing' => FALSE,
      'arbitrary_facet_plugin' => $this->getArbitraryFacetPluginId(),
    ];
    // Add the filter to the query if there are active values.
    $active_items = $this->facet->getActiveItems();
    $facet_definition = $this->getArbitraryFacetDefinition();
    if (count($active_items)) {
      $filter = $query->createConditionGroup($operator, ['arbitrary:' . $field_identifier]);

      foreach ($active_items as $active_item) {
        if (!isset($facet_definition[$active_item])) {
          throw new \Exception("Unknown active item: " . $active_item);
        }
        $active_filter = $facet_definition[$active_item];
        $field_name = $active_filter['field_name'];
        $condition = $active_filter['field_condition'];
        $operator = isset($active_filter['field_operator']) ? $active_filter['field_operator'] : NULL;
        $exclude = $exclude ? '<>' : '=';
        $filter->addCondition($field_name, $condition, $operator ?: $exclude);
      }
      $query->addConditionGroup($filter);
    }
  }

  /**
   * Load the definition of the arbitrary facet selected in the facet widget.
   *
   * @return mixed
   *   The facet definition.
   */
  protected function getArbitraryFacetDefinition() {
    /** @var \Drupal\search_api_arbitrary_facet\Plugin\ArbitraryFacetManager $arbitrary_facet_manager */
    $arbitrary_facet_manager = \Drupal::getContainer()
      ->get('plugin.manager.arbitrary_facet');
    $plugin = $arbitrary_facet_manager->createInstance($this->getArbitraryFacetPluginId());
    return $plugin->getFacetDefinition();
  }

  /**
   * Returns the plugin id selected in the widget.
   *
   * @return string
   *   The plugin id of the arbitrary facet type in use.
   */
  protected function getArbitraryFacetPluginId() {
    return $this
      ->facet
      ->getWidgetInstance()
      ->getConfiguration()['arbitrary_facet_plugin'];
  }

  /**
   * {@inheritdoc}
   */
  public function build() {
    $query_operator = $this->facet->getQueryOperator();
    $facet_definition = $this->getArbitraryFacetDefinition();

    if (!empty($this->results)) {
      $facet_results = [];
      foreach ($this->results as $result) {
        $result_filter = trim($result['filter'], '"');
        if (!isset($facet_definition[$result_filter])) {
          continue;
        }
        if ($result['count'] || $query_operator == 'or') {
          $count = $result['count'];
          $label = $facet_definition[$result_filter]['label'];
          $result = new Result($this->facet, $result_filter, $label, $count);
          $facet_results[] = $result;
        }
      }
      $this->facet->setResults($facet_results);
    }

    return $this->facet;
  }

}
