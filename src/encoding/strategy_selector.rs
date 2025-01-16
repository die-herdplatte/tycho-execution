use crate::encoding::{
    models::Solution,
    strategy_encoder::{
        SequentialStrategyEncoder, SingleSwapStrategyEncoder, SplitSwapStrategyEncoder,
        StraightToPoolStrategyEncoder, StrategyEncoder,
    },
};

pub trait StrategySelector {
    #[allow(dead_code)]
    fn select_strategy(&self, solution: &Solution) -> Box<dyn StrategyEncoder>;
}

pub struct DefaultStrategySelector;

impl StrategySelector for DefaultStrategySelector {
    fn select_strategy(&self, solution: &Solution) -> Box<dyn StrategyEncoder> {
        if solution.straight_to_pool {
            Box::new(StraightToPoolStrategyEncoder {})
        } else if solution.swaps.len() == 1 {
            Box::new(SingleSwapStrategyEncoder {})
        } else if solution
            .swaps
            .iter()
            .all(|s| s.split == 0.0)
        {
            Box::new(SequentialStrategyEncoder {})
        } else {
            Box::new(SplitSwapStrategyEncoder {})
        }
    }
}
