extends State
class_name EnemyDefendState

## State when enemy stay still on node and defend it. [br]
## Every few seconds, check if there are still Player units on the path (or they are already dead and this enemy can move) [br]
## or check if they are near to attack them