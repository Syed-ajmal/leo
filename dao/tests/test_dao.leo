// The 'test_dao' test program.
import dao.aleo;
program test_dao.aleo {
    @test
    script test_it() {
        let result: u32 = dao.aleo/main(1u32, 2u32);
        assert_eq(result, 3u32);
    }

    @test
    @should_fail
    transition do_nothing() {
        let result: u32 = dao.aleo/main(2u32, 3u32);
        assert_eq(result, 3u32);
    }

    @noupgrade
    async constructor() {}
}
