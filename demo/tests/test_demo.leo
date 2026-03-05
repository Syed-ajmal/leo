// The 'test_demo' test program.
import demo.aleo;
program test_demo.aleo {
    @test
    script test_it() {
        let result: u32 = demo.aleo/main(1u32, 2u32);
        assert_eq(result, 3u32);
    }

    @test
    @should_fail
    transition do_nothing() {
        let result: u32 = demo.aleo/main(2u32, 3u32);
        assert_eq(result, 3u32);
    }

    @noupgrade
    async constructor() {}
}
