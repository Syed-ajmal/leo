// The 'test_credit_transfer' test program.
import credit_transfer.aleo;
program test_credit_transfer.aleo {
    @test
    script test_it() {
        let result: u32 = credit_transfer.aleo/main(1u32, 2u32);
        assert_eq(result, 3u32);
    }

    @test
    @should_fail
    transition do_nothing() {
        let result: u32 = credit_transfer.aleo/main(2u32, 3u32);
        assert_eq(result, 3u32);
    }

    @noupgrade
    async constructor() {}
}
