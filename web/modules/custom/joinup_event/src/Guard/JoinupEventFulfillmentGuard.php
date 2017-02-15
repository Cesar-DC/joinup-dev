<?php

namespace Drupal\joinup_event\Guard;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\Entity\EntityTypeManagerInterface;
use Drupal\Core\Session\AccountInterface;
use Drupal\joinup_core\Guard\NodeGuard;
use Drupal\joinup_core\JoinupRelationManager;
use Drupal\joinup_core\WorkflowUserProvider;
use Drupal\og\MembershipManagerInterface;

/**
 * Class JoinupEventFulfillmentGuard.
 */
class JoinupEventFulfillmentGuard extends NodeGuard {

  /**
   * {@inheritdoc}
   */
  public function __construct(EntityTypeManagerInterface $entityTypeManager, WorkflowUserProvider $workflowUserProvider, JoinupRelationManager $relationManager, MembershipManagerInterface $ogMembershipManager, ConfigFactoryInterface $configFactory, AccountInterface $currentUser) {
    parent::__construct($entityTypeManager, $workflowUserProvider, $relationManager, $ogMembershipManager, $configFactory, $currentUser);
    $this->transitions = $this->configFactory->get('joinup_event.settings')->get('transitions');
  }

}
