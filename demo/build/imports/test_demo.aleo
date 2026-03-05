import demo.aleo;
program test_demo.aleo;

function test_reward_positive_elapsed:
    call demo.aleo/calculate_reward 1000000u64 31536000u32 into r0;
    assert.eq r0 120000u64;

constructor:
    assert.eq edition 0u16;
