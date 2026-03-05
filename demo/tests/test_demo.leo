// The 'test_demo' test program.
import demo.aleo;
program test_demo.aleo {
    @test
    script test_reward_zero_elapsed() {
        let reward: u64 = demo.aleo/calculate_reward(1_000_000u64, 0u32);
        assert_eq(reward, 0u64);
    }

    @test
    transition test_reward_positive_elapsed() {
        let reward: u64 = demo.aleo/calculate_reward(1_000_000u64, 31_536_000u32);
        assert_eq(reward, 120_000u64);
    }

    @noupgrade
    async constructor() {}
}
